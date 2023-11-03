import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:medic_app/widgets/scanner_error_widget.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/widgets/contained_button.dart';
import 'package:medic_app/widgets/custom_image_filter.dart';
import 'package:medic_app/widgets/custom_slider.dart';
import 'package:medic_app/widgets/basic_struct.dart';
import 'package:medic_app/widgets/input_form.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/services/api/basic/patient_service.dart';
import 'package:medic_app/services/api/auth/session_service.dart';

class ScanView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanView();
}

class _ScanView extends State<ScanView> {
  MobileScannerArguments? arguments;
  MobileScannerController _mobileScannerController = MobileScannerController();

  String _codeNum = '0123456789';

  late TextEditingController _searchTextEditingController;
  ValueNotifier<String> _searchText = ValueNotifier<String>('');
  late double _imageSize;

  final PatientService _patientService = PatientService();

  @override
  void initState() {
    super.initState();
    _searchTextEditingController =
        TextEditingController(text: _searchText.value);
    _searchTextEditingController.addListener(_onSearchTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  void dispose() {
    _searchTextEditingController.dispose();
    _mobileScannerController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    _searchText.value = _searchTextEditingController.text;
  }

  void _onCodeTextChanged(String value) {
    _codeNum = value;
  }

  Future<dynamic> _searchPatient(String codeNum) {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final sessionProvider = Provider.of<Session>(context, listen: false);
    platformProvider.isLoading = true;
    return _patientService
        .getPatientByCode(sessionProvider.medicData.hospitalCode ?? '', codeNum)
        .then((value) {
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
        return null;
      } else {
        return value['data'] as PatientDataRes;
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  Future<void> onDetect(BarcodeCapture barcode) async {
    _mobileScannerController.stop();
    final codeNum = barcode.barcodes.first.rawValue!;
    final patient = await _searchPatient(codeNum);
    _checkPatientExists(patient, codeNum);
    //_searchPatient(codeNum).then((value) {
    //  _checkPatientExists(value, codeNum);
    //});
  }

  void _onTapCodeInputScan() {
    _searchPatient(_codeNum).then((value) {
      _checkPatientExists(value, _codeNum);
    });
  }

  void _checkPatientExists(dynamic result, String codeNum) {
    if (result != null) {
      context.pushNamed('takePicture', extra: result as PatientDataRes);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Align(
              alignment: Alignment.center,
              child: Text('등록되지 않은 환자입니다. 신규등록이 필요합니다.')),
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))),
          margin: EdgeInsets.only(
              left: context.hPadding,
              right: context.hPadding,
              bottom: context.vPadding * 6),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2)));
      context.pushNamed('registerPatient', extra: codeNum);
    }
  }

  @override
  Widget build(BuildContext context) {
    _imageSize = context.pWidth - context.hPadding * 2;
    return BasicStruct(
      showPop: false,
      showClose: true,
      showAppBar: true,
      appBarTitle: '팔찌 인식',
      childWidget: Container(
          margin: EdgeInsets.only(top: context.vPadding * 2),
          padding:
              EdgeInsets.only(left: context.hPadding, right: context.hPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _renderCameraView(),
              Padding(
                padding: EdgeInsets.all(context.vPadding),
              ),
              _renderCodeInput(),
            ],
          )),
    );
  }

  Widget _renderCameraView() {
    return Container(
        width: _imageSize,
        height: _imageSize,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: MobileScanner(
          fit: BoxFit.fitWidth,
          controller: _mobileScannerController,
          onScannerStarted: (arguments) {
            setState(() {
              this.arguments = arguments;
            });
          },
          errorBuilder: (context, error, child) {
            return Container(
                width: _imageSize,
                height: _imageSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.blue01,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('카메라 구동이 불가능합니다.',
                    style: TextStyle(
                        color: AppColors.blue03,
                        fontSize: context.contentsTextSize,
                        fontWeight: FontWeight.bold)));
          },
          onDetect: onDetect,
        ));
  }

  Widget _renderCodeInput() {
    return InputForm(
      title: '코드 직접 입력하기',
      initData: _codeNum,
      type: TextInputType.text,
      hintText: '팔찌 번호를 입력해주세요.',
      suffixText: '입력하기',
      onCompleted: (value) => _onCodeTextChanged(value),
      onTapSuffix: () => _onTapCodeInputScan(),
    );
  }
}
