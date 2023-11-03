import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medic_app/models/api/medic_data.dart';
import 'package:medic_app/models/api/hospital_data.dart';
import 'package:provider/provider.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/widgets/basic_struct.dart';
import 'package:medic_app/widgets/pop_dialog.dart';
import 'package:medic_app/widgets/contained_button.dart';
import 'package:medic_app/widgets/data_form.dart';
import 'package:medic_app/widgets/input_form.dart';
import 'package:medic_app/utils/file.dart';
import 'package:medic_app/services/api/basic/medic_service.dart';
import 'package:medic_app/services/api/s3/auth_image_service.dart';

class MedicSignupView extends StatefulWidget {
  String? username;
  String? birthDate;
  String? phone;
  MedicSignupView({this.username, this.birthDate, this.phone});
  @override
  State<StatefulWidget> createState() => _MedicSignupView();
}

class _MedicSignupView extends State<MedicSignupView> {
  String _username = '';
  String _phone = '';
  String _phoneCheck = '';
  String _hospitalCode = '';
  String _wardCode = '';
  MedicData _medicReq = MedicData();

  FirebaseAuth _authService = FirebaseAuth.instance;
  bool _codeSent = false;
  bool _phoneVerified = true;
  String _verificationId = '';

  ValueNotifier<File?> _image = ValueNotifier<File?>(null);

  late TextEditingController _authImageInputController;
  late TextEditingController _hospitalInputController;

  ValueNotifier<bool> _isFormCompleted = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _initData();
    _authImageInputController = TextEditingController();
    _hospitalInputController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  void dispose() {
    super.dispose();
    _authImageInputController.dispose();
    _hospitalInputController.dispose();
  }

  void _initData() {
    _medicReq.username = widget.username!;
    _phone = widget.phone!;
  }

  void _onTapPositionSel(String value) {
    setState(() => _medicReq.position = value);
    _checkInputs();
  }

  void _onTypeWardCode(String val) {
    _medicReq.wardCode = val;
    _checkInputs();
  }

  void _onTypeUsername(String val) {
    _medicReq.username = val;
    _checkInputs();
  }

  void _onTypePhone(String val) {
    _phone = val;
  }

  void _onTypePhoneCheck(String val) {
    _phoneCheck = val;
  }

  void _onTapAddAuthImage() async {
    final imgFile = await context.pushNamed('addAuthImage');
    if (imgFile != null) {
      _image.value = imgFile as File;
      final pathList = imgFile.path.split('/');
      _authImageInputController.text = pathList.last;
      final base64Image = await FileHandler().convertToBase64(imgFile);
      _medicReq.authURL = base64Image;
      _checkInputs();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Align(
              alignment: Alignment.center,
              child: Text('사원증/의료증 이미지를 가져오지 못했습니다.')),
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

  void _onTapSearchHospital() async {
    HospitalData hospitalData =
        await context.pushNamed('searchHospital') as HospitalData;
    try {
      _medicReq.hospitalCode = hospitalData.hospitalName;
      _hospitalInputController.text = hospitalData.hospitalName!;
    } catch (err) {}
  }

  void _onTapSignup() async {
    _medicReq.phone = _phone;
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    final bool medicRes = await _createMedicAccount();
    if (medicRes) {
      final authImgUrl = await _postAuthImage();
      if (authImgUrl != null) {
        await _updateMedicAuthUrl(authImgUrl);
      }
      _renderDialog();
    }
    platformProvider.isLoading = false;
  }

  Future<bool> _createMedicAccount() async {
    return await MedicService().createMedic(_medicReq).then((value) {
      if (value.containsKey('err')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Align(alignment: Alignment.center, child: Text(value['err'])),
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            margin: EdgeInsets.only(
                left: context.hPadding,
                right: context.hPadding,
                bottom: context.vPadding * 6),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2)));
        return false;
      } else {
        return true;
      }
    });
  }

  Future<dynamic> _postAuthImage() async {
    return await AuthImgService()
        .postAuthImage(_phone, _image.value!)
        .then((value) {
      if (value.containsKey('err')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Align(
                alignment: Alignment.center,
                child: Text('사원증을 재업로드 해주시기 바랍니다')),
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30))),
            margin: EdgeInsets.only(
                left: context.hPadding,
                right: context.hPadding,
                bottom: context.vPadding * 6),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2)));
        return null;
      } else {
        return value['data'];
      }
    });
  }

  Future<void> _updateMedicAuthUrl(String authImgUrl) async {
    await MedicService().updateAuthUrl(_phone, authImgUrl).then((value) {
      if (value.containsKey('err')) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Align(
                alignment: Alignment.center,
                child: Text('사원증을 재업로드 해주시기 바랍니다')),
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
    });
  }

  void _checkInputs() {
    if (_medicReq.username!.isNotEmpty &&
        _medicReq.authURL!.isNotEmpty &&
        _medicReq.hospitalCode!.isNotEmpty &&
        _medicReq.wardCode!.isNotEmpty &&
        _medicReq.position!.isNotEmpty &&
        _phoneVerified) {
      _isFormCompleted.value = true;
    } else {
      _isFormCompleted.value = false;
    }
  }

  void _showErrorMsg() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Align(alignment: Alignment.center, child: Text('정보 입력을 완료해주세요.')),
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

  void _renderDialog() async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopDialog(
            textWidget: Column(children: [
              Text('의료진 가입이 완료됐습니다.',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize,
                      fontWeight: FontWeight.bold)),
              Padding(
                padding: EdgeInsets.all(context.vPadding * 0.1),
              ),
              Text('가입한 계정으로 로그인해주세요.',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: context.contentsTextSize,
                      fontWeight: FontWeight.bold)),
            ]),
            onPressed: () {
              Navigator.pop(context);
              context.goNamed('intro');
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _isFormCompleted,
        builder: (BuildContext context, bool isFormCompleted, _) {
          return BasicStruct(
              appBarTitle: '의료진 가입하기',
              bottomTapText: '가입하기',
              onTapBottom: () =>
                  isFormCompleted ? _onTapSignup() : _showErrorMsg(),
              childWidget: Container(
                  color: Colors.white,
                  width: context.pWidth,
                  margin: EdgeInsets.only(top: context.vPadding),
                  padding: EdgeInsets.only(
                      left: context.hPadding, right: context.hPadding),
                  alignment: Alignment.topCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InputForm(
                          title: '이름',
                          initData: _medicReq.username,
                          type: TextInputType.text,
                          onCompleted: (value) => _onTypeUsername(value)),
                      Padding(padding: EdgeInsets.all(context.hPadding * 0.5)),
                      DataForm(
                        title: '직책',
                        formWidget: _roleInput(),
                      ),
                      Padding(
                        padding: EdgeInsets.all(context.hPadding * 0.5),
                      ),
                      DataForm(
                        title: '소속병원',
                        formWidget: _hospitalInput(),
                      ),
                      Padding(padding: EdgeInsets.all(context.vPadding * 1.2)),
                      InputForm(
                          title: '소속과',
                          initData: _wardCode,
                          type: TextInputType.text,
                          hintText: '소속과를 입력해주세요',
                          onCompleted: (value) => _onTypeWardCode(value)),
                      Padding(padding: EdgeInsets.all(context.vPadding * 1.2)),
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
                      DataForm(
                        title: '의료증/사원증 등록',
                        formWidget: _authImageInput(),
                      )
                    ],
                  )));
        });
  }

  Widget _authImageInput() {
    return ValueListenableBuilder(
        valueListenable: _image,
        builder: (BuildContext context, File? file, _) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    width: context.pWidth,
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(color: AppColors.gray02))),
                    padding: EdgeInsets.only(bottom: context.vPadding * 0.5),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              flex: 2,
                              child: TextField(
                                  controller: _authImageInputController,
                                  enabled: false,
                                  textAlign: TextAlign.start,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.only(
                                        left: 0, bottom: context.vPadding),
                                    hintText: '사진을 등록해주세요.',
                                    hintStyle: const TextStyle(
                                        color: Colors.black54,
                                        fontWeight: FontWeight.normal),
                                    fillColor: Colors.white,
                                    filled: true,
                                    constraints: BoxConstraints(
                                      maxWidth: context.pWidth,
                                      maxHeight: context.pHeight * 0.05,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: context.contentsTextSize,
                                  ))),
                          Expanded(
                              child: Container(
                                  alignment: Alignment.centerRight,
                                  child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                          onTap: () => _onTapAddAuthImage(),
                                          borderRadius: BorderRadius.circular(
                                              context.hPadding * 0.8),
                                          child: Container(
                                              padding: EdgeInsets.only(
                                                top: context.hPadding * 0.3,
                                                bottom: context.hPadding * 0.3,
                                                left: context.hPadding * 0.5,
                                                right: context.hPadding * 0.5,
                                              ),
                                              decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  border: Border.all(
                                                      color:
                                                          AppColors.mainColor,
                                                      width: 1),
                                                  borderRadius: BorderRadius.circular(
                                                      context.hPadding * 0.8)),
                                              child: Text(
                                                  file != null
                                                      ? '사진 변경'
                                                      : '사진 촬영/첨부',
                                                  style: TextStyle(
                                                      color:
                                                          AppColors.mainColor,
                                                      fontSize: context
                                                              .contentsTextSize *
                                                          0.8)))))))
                        ])),
                file != null
                    ? Container(
                        width: context.pWidth * 0.4,
                        height: context.pWidth * 0.4,
                        margin: EdgeInsets.only(top: context.vPadding),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: FileImage(file), fit: BoxFit.cover),
                        ))
                    : const SizedBox()
              ]);
        });
  }

  Widget _roleInput() {
    return SizedBox(
        width: context.pWidth,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: ContainedButton(
                  onPressed: () => _onTapPositionSel('doctor'),
                  color: _medicReq.position == 'doctor'
                      ? AppColors.mainColor
                      : Colors.white,
                  borderColor: _medicReq.position == 'doctor'
                      ? Colors.transparent
                      : AppColors.blue03,
                  text: '의사',
                  textSize: context.contentsTextSize,
                  textColor: _medicReq.position == 'doctor'
                      ? Colors.white
                      : AppColors.blue03)),
          Padding(padding: EdgeInsets.all(context.hPadding * 0.5)),
          Expanded(
              child: ContainedButton(
                  onPressed: () => _onTapPositionSel('nurse'),
                  color: _medicReq.position == 'nurse'
                      ? AppColors.mainColor
                      : Colors.white,
                  borderColor: _medicReq.position == 'nurse'
                      ? Colors.transparent
                      : AppColors.blue03,
                  text: '간호사',
                  textSize: context.contentsTextSize,
                  textColor: _medicReq.position == 'nurse'
                      ? Colors.white
                      : AppColors.blue03)),
        ]));
  }

  Widget _hospitalInput() {
    return Container(
        width: context.pWidth,
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.gray02))),
        padding: EdgeInsets.only(bottom: context.vPadding * 0.5),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              flex: 4,
              child: TextField(
                  controller: _hospitalInputController,
                  enabled: false,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.only(left: 0, bottom: context.vPadding),
                    hintText: '병원을 입력해주세요',
                    hintStyle: const TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.normal),
                    fillColor: Colors.white,
                    filled: true,
                    constraints: BoxConstraints(
                      maxWidth: context.pWidth,
                      maxHeight: context.pHeight * 0.05,
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: context.contentsTextSize,
                  ))),
          Expanded(
              child: Container(
                  alignment: Alignment.centerRight,
                  child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                          onTap: () => _onTapSearchHospital(),
                          borderRadius:
                              BorderRadius.circular(context.hPadding * 0.8),
                          child: Container(
                              padding: EdgeInsets.only(
                                top: context.hPadding * 0.3,
                                bottom: context.hPadding * 0.3,
                                left: context.hPadding * 0.5,
                                right: context.hPadding * 0.5,
                              ),
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                      color: AppColors.mainColor, width: 1),
                                  borderRadius: BorderRadius.circular(
                                      context.hPadding * 0.8)),
                              child: Text('병원 검색',
                                  style: TextStyle(
                                      color: AppColors.mainColor,
                                      fontSize:
                                          context.contentsTextSize * 0.8)))))))
        ]));
  }
}
