import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medic_app/services/api/basic/fcm_token_service.dart';
import 'package:provider/provider.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/widgets/basic_struct.dart';
import 'package:medic_app/widgets/contained_button.dart';
import 'package:medic_app/widgets/input_form.dart';
import 'package:medic_app/widgets/data_form.dart';
import 'package:medic_app/services/api/auth/session_service.dart';
import 'package:medic_app/services/encrypted_storage_service.dart';

class SigninView extends StatefulWidget {
  int userDiv;
  SigninView({required this.userDiv});
  @override
  State<StatefulWidget> createState() => _SigninView();
}

class _SigninView extends State<SigninView> {
  String _phone = '01045619502';
  FirebaseAuth _authService = FirebaseAuth.instance;
  bool _codeSent = false;
  bool _phoneVerified = true;
  String _verificationId = '';
  String _phoneCheck = '';
  ValueNotifier<bool> _isFormCompleted = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _onTypePhone(String val) {
    setState(() => _phone = val);
  }

  void _onTypePhoneCheck(String val) {
    _phoneCheck = val;
  }

  void _onTapSendPhoneCheck() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final phoneNumber = '+82${_phone.substring(1)}';
    platformProvider.isLoading = true;
    setState(() => _phoneVerified = false);
    await _authService
        .verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) {},
          verificationFailed: (FirebaseAuthException e) {
            String errMsg;
            if (e.code == 'invalid-phone-number') {
              errMsg = "유효하지 않은 전화번호입니다. 재입력해주세요";
            } else {
              errMsg = e.message ?? "UNKNOWN_ERROR";
            }
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Align(alignment: Alignment.center, child: Text(errMsg)),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30))),
                margin: EdgeInsets.only(
                    left: context.hPadding,
                    right: context.hPadding,
                    bottom: context.vPadding * 6),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2)));
          },
          codeSent: (String verificationId, forceResendingToken) async {
            setState(() {
              _codeSent = true;
              _verificationId = verificationId;
            });
          },
          codeAutoRetrievalTimeout: (verificationId) {
            print("handling code auto retrieval timeout");
          },
        )
        .whenComplete(() =>
            Provider.of<Platform>(context, listen: false).isLoading = false);
  }

  void _onTapVerifyPhone() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId, smsCode: _phoneCheck);
    await _authService.signInWithCredential(credential).then((_) {
      setState(() => _phoneVerified = true);
      _checkInputs();
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _onTapSignin() {
    final role = widget.userDiv == 0 ? 'user' : 'medic';
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    SessionService().signIn(_phone, role).then((value) async {
      if (value.containsKey('err')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Align(
                alignment: Alignment.center, child: Text('로그인 정보를 확인해주세요')),
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            margin: EdgeInsets.only(
                left: context.hPadding,
                right: context.hPadding,
                bottom: context.vPadding * 6),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2)));
      } else {
        await _saveSession(value['data']);
        _updateFcmToken().whenComplete(() => context.goNamed('home'));
      }
    }).whenComplete(() {
      platformProvider.isLoading = false;
    });
  }

  Future<void> _saveSession(dynamic sessionData) async {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    sessionProvider.isAuthorized = true;
    sessionProvider.role = widget.userDiv == 0 ? 'user' : 'medic';
    final authData = AuthData.fromJson(sessionData['authData']);
    await EncryptedStorageService().initStorage();
    await EncryptedStorageService()
        .saveData("access_token", authData.accessToken ?? "");
    await EncryptedStorageService()
        .saveData("refresh_token", authData.refreshToken ?? "")
        .whenComplete(() {
      if (widget.userDiv == 1) {
        sessionProvider.medicData =
            MedicData.fromJson(sessionData['accountData']);
      } else if (widget.userDiv == 0) {
        sessionProvider.userData =
            UserDataRes.fromJson(sessionData['accountData']);
      }
    });
  }

  Future<void> _updateFcmToken() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    await FcmTokenService()
        .createFcmToken(_phone, platformProvider.fcmToken)
        .whenComplete(() => platformProvider.isLoading = false);
  }

  void _checkInputs() {
    if (_phone.isNotEmpty && _phoneVerified) {
      _isFormCompleted.value = true;
    } else {
      _isFormCompleted.value = false;
    }
  }

  void _showErrorMsg() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Align(
            alignment: Alignment.center, child: Text('로그인 정보 입력을 완료해주세요.')),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30))),
        margin: EdgeInsets.only(
            left: context.hPadding,
            right: context.hPadding,
            bottom: context.vPadding * 6),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _isFormCompleted,
        builder: (BuildContext context, bool isFormCompleted, _) {
          return BasicStruct(
              childWidget: Container(
                  color: Colors.white,
                  width: context.pWidth,
                  height: context.pHeight,
                  alignment: Alignment.topCenter,
                  padding: EdgeInsets.only(
                      left: context.hPadding, right: context.hPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InputForm(
                          title: '휴대폰',
                          initData: _phone,
                          type: TextInputType.number,
                          hintText: '숫자만 입력해주세요',
                          suffixText: '인증요청',
                          onTapSuffix: () => _onTapSendPhoneCheck(),
                          onCompleted: (value) => _onTypePhone(value)),
                      Padding(padding: EdgeInsets.all(context.vPadding * 1.2)),
                      _codeSent
                          ? InputForm(
                              title: '휴대폰 인증번호',
                              initData: _phoneCheck,
                              type: TextInputType.number,
                              hintText: '인증번호 6자리',
                              suffixText: _phoneVerified ? '인증완료' : '인증하기',
                              suffixTappable: !_phoneVerified,
                              onTapSuffix: () =>
                                  _phoneVerified ? null : _onTapVerifyPhone(),
                              onCompleted: (value) => _onTypePhoneCheck(value))
                          : const SizedBox(),
                      _codeSent
                          ? Padding(
                              padding: EdgeInsets.all(context.vPadding * 1.2))
                          : const SizedBox(),
                      ContainedButton(
                        color: Colors.black87,
                        text: '로그인',
                        textColor: Colors.white,
                        onPressed: () =>
                            isFormCompleted ? _onTapSignin() : _showErrorMsg(),
                      ),
                    ],
                  )));
        });
  }
}
