import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/widgets/basic_struct.dart';
import 'package:medic_app/widgets/contained_button.dart';
import 'package:medic_app/widgets/input_form.dart';
import 'package:medic_app/widgets/pop_dialog.dart';
import 'package:medic_app/widgets/data_form.dart';
import 'package:medic_app/services/api/basic/user_service.dart';
import 'package:medic_app/utils/datetime.dart';

class CustomerSignupView extends StatefulWidget {
  String? username;
  String? birthDate;
  String? phone;
  CustomerSignupView({this.username, this.birthDate, this.phone});
  @override
  State<StatefulWidget> createState() => _CustomerSignupView();
}

class _CustomerSignupView extends State<CustomerSignupView> {
  String _birthDateY = '';
  String _birthDateM = '';
  String _birthDateD = '';
  String _phone = '';
  String _phoneCheck = '';
  String _sickness = '';
  UserDataReq _userDataToPost = UserDataReq();

  FirebaseAuth _authService = FirebaseAuth.instance;
  bool _codeSent = false;
  bool _phoneVerified = false;
  String _verificationId = '';

  ValueNotifier<bool> _isFormCompleted = ValueNotifier<bool>(false);

  late TextEditingController _addressInputController;

  @override
  void initState() {
    super.initState();
    _initData();
    _addressInputController =
        TextEditingController(text: _userDataToPost.address ?? '');
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  void dispose() {
    super.dispose();
    _addressInputController.dispose();
  }

  void _initData() {
    _userDataToPost.username = widget.username!;
    _phone = widget.phone!;
  }

  void _onTypeUsername(String val) {
    _userDataToPost.username = val;
    _checkInputs();
  }

  void _onTapGenderSel(String value) {
    setState(() => _userDataToPost.gender = value);
    _checkInputs();
  }

  void _onTypeBirthDateYear(String val) {
    _birthDateY = val;
    _checkInputs();
  }

  void _onTypeBirthDateMonth(String val) {
    _birthDateM = val;
    _checkInputs();
  }

  void _onTypeBirthDateDay(String val) {
    _birthDateD = val;
    _checkInputs();
  }

  void _onTypePhone(String val) {
    _phone = val;
  }

  void _onTypePhoneCheck(String val) {
    _phoneCheck = val;
  }

  void _onTapSearchAddress() async {
    AddressData address =
        await context.pushNamed('searchAddress') as AddressData;
    try {
      _userDataToPost.address = address.basicAddress;
      _addressInputController.text = address.basicAddress!;
    } catch (err) {}
  }

  void _onTypeSickness(String val) {
    _sickness = val;
  }

  void _onTapSendPhoneCheck() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final phoneNumber = '+82${_phone.substring(1)}';
    platformProvider.isLoading = true;
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
            print(verificationId);
          },
          codeAutoRetrievalTimeout: (verificationId) {
            print("handling code auto retrieval timeout");
          },
        )
        .whenComplete(() => platformProvider.isLoading = false);
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

  void _onTapSignup() {
    final birthDate =
        Datetime().getServerDatetime(_birthDateY, _birthDateM, _birthDateD);
    _userDataToPost.phone = _phone;
    _userDataToPost.birthDate = birthDate;

    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    UserService().createUser(_userDataToPost).then((value) {
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
      } else {
        _renderDialog();
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _checkInputs() {
    if (_userDataToPost.username!.isNotEmpty &&
        _userDataToPost.gender!.isNotEmpty &&
        _birthDateY.isNotEmpty &&
        _birthDateM.isNotEmpty &&
        _birthDateD.isNotEmpty &&
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
              Text('고객 가입이 완료됐습니다.',
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
              appBarTitle: '고객 가입하기',
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
                          initData: _userDataToPost.username,
                          type: TextInputType.text,
                          hintText: '이름을 입력해주세요',
                          onCompleted: (value) => _onTypeUsername(value)),
                      Padding(padding: EdgeInsets.all(context.vPadding * 1.2)),
                      DataForm(
                        title: '성별',
                        formWidget: _genderInput(),
                      ),
                      Padding(padding: EdgeInsets.all(context.vPadding * 1.2)),
                      DataForm(
                        title: '생년월일',
                        formWidget: _birthDateInput(),
                      ),
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
                        title: '주소(선택)',
                        formWidget: _addressInput(),
                      ),
                      Padding(padding: EdgeInsets.all(context.vPadding * 1.2)),
                      InputForm(
                          title: '아픈 부위(자유)',
                          initData: _sickness,
                          type: TextInputType.text,
                          hintText: '입력해주세요',
                          onCompleted: (value) => _onTypeSickness(value)),
                    ],
                  )));
        });
  }

  Widget _genderInput() {
    return SizedBox(
        width: context.pWidth,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: ContainedButton(
                  onPressed: () => _onTapGenderSel('M'),
                  color: _userDataToPost.gender == 'M'
                      ? AppColors.mainColor
                      : Colors.white,
                  borderColor: _userDataToPost.gender == 'M'
                      ? Colors.transparent
                      : AppColors.blue03,
                  text: '남성',
                  textSize: context.contentsTextSize,
                  textColor: _userDataToPost.gender == 'M'
                      ? Colors.white
                      : AppColors.blue03)),
          Padding(padding: EdgeInsets.all(context.hPadding * 0.5)),
          Expanded(
              child: ContainedButton(
                  onPressed: () => _onTapGenderSel('F'),
                  color: _userDataToPost.gender == 'F'
                      ? AppColors.mainColor
                      : Colors.white,
                  borderColor: _userDataToPost.gender == 'F'
                      ? Colors.transparent
                      : AppColors.blue03,
                  text: '여성',
                  textSize: context.contentsTextSize,
                  textColor: _userDataToPost.gender == 'F'
                      ? Colors.white
                      : AppColors.blue03)),
        ]));
  }

  Widget _birthDateInput() {
    return Container(
        width: context.pWidth,
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.gray02))),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                maxLength: 4,
                keyboardType: TextInputType.number,
                onChanged: (val) => _onTypeBirthDateYear(val),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 0, right: 0),
                    hintText: 'YYYY',
                    hintStyle: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.normal),
                    fillColor: Colors.white,
                    filled: true,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    counterText: ""),
              ),
            ),
            Container(
                margin: EdgeInsets.only(
                  left: context.hPadding,
                  right: context.hPadding,
                ),
                width: 1,
                height: context.vPadding * 2,
                color: AppColors.gray02),
            Expanded(
              flex: 2,
              child: TextField(
                maxLength: 2,
                keyboardType: TextInputType.number,
                onChanged: (val) => _onTypeBirthDateMonth(val),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 0, right: 0),
                    hintText: 'MM',
                    hintStyle: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.normal),
                    fillColor: Colors.white,
                    filled: true,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    counterText: ""),
              ),
            ),
            Container(
                margin: EdgeInsets.only(
                  left: context.hPadding,
                  right: context.hPadding,
                ),
                width: 1,
                height: context.vPadding * 2,
                color: AppColors.gray02),
            Expanded(
              flex: 2,
              child: TextField(
                maxLength: 2,
                keyboardType: TextInputType.number,
                onChanged: (val) => _onTypeBirthDateDay(val),
                decoration: const InputDecoration(
                    contentPadding: EdgeInsets.only(left: 0, right: 0),
                    hintText: 'DD',
                    hintStyle: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.normal),
                    fillColor: Colors.white,
                    filled: true,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    counterText: ""),
              ),
            ),
          ],
        ));
  }

  Widget _addressInput() {
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
                  controller: _addressInputController,
                  enabled: false,
                  textAlign: TextAlign.start,
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.only(left: 0, bottom: context.vPadding),
                    hintText: '주소 검색을 통해 입력해주세요.',
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
                          onTap: () => _onTapSearchAddress(),
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
                              child: Text('주소검색',
                                  style: TextStyle(
                                      color: AppColors.mainColor,
                                      fontSize:
                                          context.contentsTextSize * 0.8)))))))
        ]));
  }
}
