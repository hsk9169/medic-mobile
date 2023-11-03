import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/widgets/basic_struct.dart';
import 'package:medic_app/widgets/contained_button.dart';
import 'package:medic_app/services/api/basic/patient_service.dart';
import 'package:medic_app/widgets/input_form.dart';
import 'package:medic_app/widgets/data_form.dart';
import 'package:medic_app/utils/datetime.dart';

class RegisterView extends StatefulWidget {
  String codeNum;
  RegisterView({required this.codeNum});
  @override
  State<StatefulWidget> createState() => _RegisterView();
}

class _RegisterView extends State<RegisterView> {
  final PatientService _patientService = PatientService();
  PatientDataReq _patientDataToPost = PatientDataReq();

  String _birthDateY = '';
  String _birthDateM = '';
  String _birthDateD = '';

  ValueNotifier<bool> _isFormCompleted = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _initData() {
    final medicData = Provider.of<Session>(context, listen: false).medicData;
    _patientDataToPost.nurseName = medicData.username;
    _patientDataToPost.code = widget.codeNum;
    _patientDataToPost.hospitalCode = medicData.hospitalCode;
  }

  void _onTapRegister() {
    _registerPatient().then((value) {
      if (value) {
        context.goNamed('takePicture',
            extra: PatientDataRes(
              name: _patientDataToPost.name,
              gender: _patientDataToPost.gender,
              age: Datetime().getAgeFromDatetime(_patientDataToPost.birthDate!),
              code: _patientDataToPost.code,
              nurseName: _patientDataToPost.nurseName,
              doctorName: _patientDataToPost.doctorName,
              roomCode: _patientDataToPost.roomCode,
            ));
      }
    });
  }

  void _onTypeUsername(String val) {
    setState(() => _patientDataToPost.name = val);
    _checkInputs();
  }

  void _onTypePhone(String val) {
    setState(() => _patientDataToPost.phone = val);
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

  void _onTypeWardCode(String val) {
    setState(() => _patientDataToPost.roomCode = val);
    _checkInputs();
  }

  void _onTypeDoctorName(String val) {
    setState(() => _patientDataToPost.doctorName = val);
    _checkInputs();
  }

  Future<bool> _registerPatient() {
    final birthDate =
        Datetime().getServerDatetime(_birthDateY, _birthDateM, _birthDateD);
    _patientDataToPost.birthDate = birthDate;
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    return _patientService.createPatient(_patientDataToPost).then((value) {
      if (value.containsKey('err')) {
        if (value['err'] == _patientService.unauthorizedFlag) {
          Provider.of<Session>(context, listen: false).isAuthorized = false;
        } else {
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
        }
        return false;
      } else {
        return true;
      }
    }).whenComplete(() => platformProvider.isLoading = false);
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

  void _checkInputs() {
    if (_patientDataToPost.name!.isNotEmpty &&
        _patientDataToPost.gender!.isNotEmpty &&
        _birthDateY.isNotEmpty &&
        _birthDateM.isNotEmpty &&
        _birthDateD.isNotEmpty &&
        _patientDataToPost.phone!.isNotEmpty &&
        _patientDataToPost.roomCode!.isNotEmpty &&
        _patientDataToPost.doctorName!.isNotEmpty &&
        _patientDataToPost.code!.isNotEmpty) {
      _isFormCompleted.value = true;
    } else {
      _isFormCompleted.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _isFormCompleted,
        builder: (BuildContext context, bool isFormCompleted, _) {
          return BasicStruct(
              showClose: true,
              appBarTitle: '환자 등록',
              bottomTapText: '등록하기',
              onTapBottom: () =>
                  isFormCompleted ? _onTapRegister() : _showErrorMsg(),
              childWidget: Container(
                  color: Colors.white,
                  alignment: Alignment.topCenter,
                  margin: EdgeInsets.only(top: context.vPadding),
                  padding: EdgeInsets.only(
                    left: context.hPadding,
                    right: context.hPadding,
                  ),
                  width: context.pWidth,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        InputForm(
                            title: '이름',
                            initData: _patientDataToPost.name,
                            type: TextInputType.text,
                            hintText: '이름을 입력해주세요',
                            onCompleted: (value) => _onTypeUsername(value)),
                        Padding(
                            padding: EdgeInsets.all(context.vPadding * 1.2)),
                        DataForm(
                          title: '성별',
                          formWidget: _genderInput(),
                        ),
                        Padding(
                            padding: EdgeInsets.all(context.vPadding * 1.2)),
                        DataForm(
                          title: '생년월일',
                          formWidget: _birthDateInput(),
                        ),
                        Padding(
                            padding: EdgeInsets.all(context.vPadding * 1.2)),
                        InputForm(
                            title: '휴대폰',
                            initData: _patientDataToPost.phone,
                            type: TextInputType.number,
                            hintText: '숫자만 입력해주세요',
                            onCompleted: (value) => _onTypePhone(value)),
                        Padding(
                            padding: EdgeInsets.all(context.vPadding * 1.2)),
                        InputForm(
                            title: '현재 병실',
                            initData: _patientDataToPost.roomCode,
                            type: TextInputType.number,
                            hintText: '병실 호수를 입력해주세요',
                            onCompleted: (value) => _onTypeWardCode(value)),
                        Padding(
                            padding: EdgeInsets.all(context.vPadding * 1.2)),
                        InputForm(
                            title: '담당 의사',
                            initData: _patientDataToPost.doctorName,
                            type: TextInputType.text,
                            hintText: '담당 의사 성함을 입력해주세요',
                            onCompleted: (value) => _onTypeDoctorName(value)),
                        Padding(
                            padding: EdgeInsets.all(context.vPadding * 1.2)),
                        InputForm(
                          title: '환자 코드',
                          initData: widget.codeNum,
                          isEdittable: false,
                          type: TextInputType.text,
                          //onCompleted: (value) => _onTypeUsername(value)
                        ),
                        Padding(
                            padding: EdgeInsets.all(context.vPadding * 1.2)),
                      ])));
        });
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
                  counterText: "",
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(
                  left: context.hPadding,
                  right: context.hPadding,
                ),
                width: 1,
                height: context.vPadding * 2,
                color: AppColors.gray01),
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
                  counterText: "",
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(
                  left: context.hPadding,
                  right: context.hPadding,
                ),
                width: 1,
                height: context.vPadding * 2,
                color: AppColors.gray01),
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
                  counterText: "",
                ),
              ),
            ),
          ],
        ));
  }

  Widget _genderInput() {
    return SizedBox(
        width: context.pWidth,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: ContainedButton(
                  onPressed: () =>
                      setState(() => _patientDataToPost.gender = 'M'),
                  color: _patientDataToPost.gender == 'M'
                      ? AppColors.mainColor
                      : Colors.white,
                  borderColor: _patientDataToPost.gender == 'M'
                      ? Colors.transparent
                      : AppColors.blue03,
                  text: '남성',
                  textSize: context.contentsTextSize,
                  textColor: _patientDataToPost.gender == 'M'
                      ? Colors.white
                      : AppColors.blue03)),
          Padding(padding: EdgeInsets.all(context.hPadding * 0.5)),
          Expanded(
              child: ContainedButton(
                  onPressed: () =>
                      setState(() => _patientDataToPost.gender = 'F'),
                  color: _patientDataToPost.gender == 'F'
                      ? AppColors.mainColor
                      : Colors.white,
                  borderColor: _patientDataToPost.gender == 'F'
                      ? Colors.transparent
                      : AppColors.blue03,
                  text: '여성',
                  textSize: context.contentsTextSize,
                  textColor: _patientDataToPost.gender == 'F'
                      ? Colors.white
                      : AppColors.blue03)),
        ]));
  }
}
