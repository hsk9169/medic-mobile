import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/services/api/s3/feed_service.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/widgets/contained_button.dart';
import 'package:medic_app/widgets/custom_image_filter.dart';
import 'package:medic_app/widgets/custom_slider.dart';
import 'package:medic_app/widgets/input_form.dart';
import 'package:medic_app/widgets/basic_struct.dart';
import 'package:medic_app/widgets/profile_card_simple.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/services/api/basic/patient_service.dart';
import 'package:medic_app/utils/hash.dart';

class CameraView extends StatefulWidget {
  final PatientDataRes patientData;
  const CameraView({required this.patientData, Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _CameraView();
}

class _CameraView extends State<CameraView> {
  late CameraController _cameraController;
  late Future<void> _initializeCameraControllerFuture;

  ValueNotifier<File?> _image = ValueNotifier<File?>(null);
  File? _originImage;
  late double _imageSize;
  bool _isTakingPic = false;
  String _tag = '';
  String _msg = '';
  FeedPostReq _feedToPost = FeedPostReq(files: [], originFiles: []);

  late Future<dynamic> _patientDataFuture;

  ValueNotifier<double> _hue = ValueNotifier<double>(0.0);
  ValueNotifier<double> _brightness = ValueNotifier<double>(0.0);
  ValueNotifier<double> _saturation = ValueNotifier<double>(0.0);

  ValueNotifier<bool> _isFormCompleted = ValueNotifier<bool>(true);

  GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    final camera = Provider.of<Platform>(context, listen: false).camera;
    _cameraController = CameraController(
      Provider.of<Platform>(context, listen: false).camera,
      ResolutionPreset.high,
    );
    if (camera != null) {
      _initializeCameraControllerFuture = _cameraController.initialize();
    } else {
      _initializeCameraControllerFuture = Future.value(null);
    }
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<Platform>(context, listen: false).isLoading = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController.dispose();
  }

  void _initData() async {
    _patientDataFuture = _getPatientData();
    _feedToPost.patientId = widget.patientData.id;
    _feedToPost.feedMeta = FeedMeta(
      authorId: HashFunc().getHash(
          Provider.of<Session>(context, listen: false).medicData.phone ?? ''),
    );
  }

  Future<dynamic> _getPatientData() {
    final sessionProvider = Provider.of<Session>(context, listen: false);
    final platformProvider = Provider.of<Platform>(context, listen: false);
    return PatientService()
        .getPatientByCode(sessionProvider.medicData.hospitalCode ?? '',
            widget.patientData.code ?? '')
        .then((value) {
      if (value.containsKey('err')) {
        if (value['err'] == PatientService().unauthorizedFlag) {
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
        _feedToPost.patientId = value['data'].id ?? '';
        return value['data'];
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _onTapTakingPicture() async {
    setState(() => _isTakingPic = true);
    try {
      await _initializeCameraControllerFuture;
      final picture = await _cameraController.takePicture();
      _image.value = File(picture.path);
      _feedToPost.originFiles!.add(_image.value!);
      _checkInputs();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Align(alignment: Alignment.center, child: Text(e.toString())),
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
    setState(() => _isTakingPic = false);
  }

  void _checkInputs() {
    if (_feedToPost.originFiles!.isNotEmpty) {
      _isFormCompleted.value = true;
    } else {
      _isFormCompleted.value = false;
    }
  }

  void _adjustFilter() {
    showModalBottomSheet(
        elevation: 30,
        barrierColor: Colors.transparent,
        enableDrag: false,
        isDismissible: true,
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.hPadding),
        ),
        builder: (BuildContext context) => _renderFilterView(context));
  }

  void _onHueChanged(val) {
    setState(() => _hue.value = val);
  }

  void _onBrightnessChanged(val) {
    setState(() => _brightness.value = val);
  }

  void _onSaturationChanged(val) {
    setState(() => _saturation.value = val);
  }

  void _onTypeTag(String value) {
    setState(() => _tag = value);
  }

  void _onTypeMsg(String value) {
    setState(() => _msg = value);
    _feedToPost.feedMeta!.postContent = value;
  }

  void _onTapPost() async {
    await _getFilteredImage().then((value) {
      _feedToPost.files!.add(value);
    });
    await _postFeed().then((value) {
      if (value) {
        context.goNamed('patientPage', extra: widget.patientData);
      }
    });
  }

  Future<bool> _postFeed() {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    return FeedService().postFeed(_feedToPost).then((value) {
      if (value.containsKey('err')) {
        if (value['err'] == FeedService().unauthorizedFlag) {
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

  Future<File> _getFilteredImage() async {
    final RenderRepaintBoundary rojecet = _repaintBoundaryKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    final ui.Image tempScreen = await rojecet.toImage(
        pixelRatio: MediaQuery.of(_repaintBoundaryKey.currentContext!)
            .devicePixelRatio);
    final ByteData? byteData =
        await tempScreen.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List png8Bytes = byteData!.buffer.asUint8List();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    final File tempFile = File("$tempPath/${DateTime.now().toString()}");
    final File filteredImage = await tempFile.writeAsBytes(png8Bytes);
    return filteredImage;
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

  @override
  Widget build(BuildContext context) {
    _imageSize = context.pWidth - context.hPadding * 2;
    return ValueListenableBuilder(
        valueListenable: _isFormCompleted,
        builder: (BuildContext context, bool isFormCompleted, _) {
          return BasicStruct(
              showClose: true,
              appBarTitle: '상태 촬영',
              bottomTapText: '등록하기',
              onTapBottom: () =>
                  isFormCompleted ? _onTapPost() : _showErrorMsg(),
              childWidget: Container(
                  color: Colors.white,
                  width: context.pWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _renderPatientProfile(),
                      Padding(padding: EdgeInsets.all(context.vPadding)),
                      Container(
                          padding: EdgeInsets.only(
                            left: context.hPadding,
                            right: context.hPadding,
                          ),
                          child: Column(children: [
                            _renderCameraView(),
                            Padding(padding: EdgeInsets.all(context.vPadding)),
                            // InputForm(
                            // title: '태그',
                            // type: TextInputType.text,
                            // hintText: '#태그 #태그',
                            // onCompleted: (value) => _onTypeTag(value),
                            // ),
                            // Padding(padding: EdgeInsets.all(context.vPadding)),
                            InputForm(
                              title: '메시지',
                              type: TextInputType.text,
                              hintText: '123456',
                              onCompleted: (value) => _onTypeMsg(value),
                            ),
                          ]))
                    ],
                  )));
        });
  }

  Widget _renderPatientProfile() {
    return FutureBuilder(
        future: _patientDataFuture,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            return Container(
                padding: EdgeInsets.only(
                  left: context.hPadding,
                  right: context.hPadding,
                  top: context.vPadding,
                  bottom: context.vPadding,
                ),
                decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: AppColors.gray01))),
                child: ProfileCardSimple(patient: snapshot.data));
          } else {
            return const SizedBox();
          }
        });
  }

  Widget _renderCameraView() {
    return ValueListenableBuilder(
        valueListenable: _image,
        builder: (BuildContext context, File? image, _) {
          return Container(
              width: _imageSize,
              height: _imageSize,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.hPadding)),
              child: image == null ? _renderCamera() : _renderImageEdit());
        });
  }

  Widget _renderCamera() {
    return FutureBuilder<void>(
      future: _initializeCameraControllerFuture,
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            _cameraController.cameraId >= 0) {
          return Stack(children: [
            SizedBox(
              width: context.pWidth,
              height: context.pWidth,
              child: FittedBox(
                fit: BoxFit.fitWidth,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: context.pWidth,
                  height: context.pWidth * _cameraController.value.aspectRatio,
                  child: CameraPreview(_cameraController),
                ),
              ),
            ),
            Container(
              width: _imageSize,
              height: _imageSize,
              padding: EdgeInsets.all(context.hPadding * 0.5),
              alignment: Alignment.bottomRight,
              child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _isTakingPic ? null : _onTapTakingPicture(),
                      child: Container(
                          width: context.pWidth * 0.15,
                          height: context.pWidth * 0.15,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.mainColor),
                          child: Icon(Icons.camera_alt,
                              color: Colors.white,
                              size: context.pWidth * 0.1)))),
            ),
          ]);
        } else {
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
        }
      },
    );
  }

  Widget _renderImageEdit() {
    return SizedBox(
        width: _imageSize,
        height: _imageSize,
        child: Stack(children: [
          RepaintBoundary(
              key: _repaintBoundaryKey,
              child: CustomImageFilter(
                  hue: _hue.value,
                  brightness: _brightness.value,
                  saturation: _saturation.value,
                  image: _image.value!)),
          Container(
              padding: EdgeInsets.all(context.hPadding * 0.5),
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _adjustFilter(),
                          child: Container(
                              width: context.pWidth * 0.15,
                              height: context.pWidth * 0.15,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.mainColor),
                              child: Icon(Icons.auto_fix_high_outlined,
                                  color: Colors.white,
                                  size: context.pWidth * 0.1)))),
                  Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _image.value = null,
                          child: Container(
                              width: context.pWidth * 0.15,
                              height: context.pWidth * 0.15,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.mainColor),
                              child: Icon(Icons.camera_alt,
                                  color: Colors.white,
                                  size: context.pWidth * 0.1)))),
                ],
              ))
        ]));
  }

  Widget _renderFilterView(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.hPadding),
        ),
        padding: EdgeInsets.only(
          top: context.vPadding * 0.5,
          left: context.hPadding,
          right: context.hPadding,
          bottom: context.vPadding * 0.5,
        ),
        width: context.pWidth,
        height: context.pHeight * 0.4,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                      padding: EdgeInsets.all(context.hPadding * 0.5),
                      child: Icon(Icons.close, color: Colors.black)))),
          ValueListenableBuilder(
              valueListenable: _hue,
              builder: (BuildContext context, double value, Widget? child) {
                return CustomSlider(
                    onChanged: (val) => _onHueChanged(val),
                    title: '색조',
                    adjustValue: value);
              }),
          Padding(
            padding: EdgeInsets.all(context.vPadding),
          ),
          ValueListenableBuilder(
              valueListenable: _brightness,
              builder: (BuildContext context, double value, Widget? child) {
                return CustomSlider(
                    onChanged: (val) => _onBrightnessChanged(val),
                    title: '밝기',
                    adjustValue: value);
              }),
          Padding(
            padding: EdgeInsets.all(context.vPadding),
          ),
          ValueListenableBuilder(
              valueListenable: _saturation,
              builder: (BuildContext context, double value, Widget? child) {
                return CustomSlider(
                    onChanged: (val) => _onSaturationChanged(val),
                    title: '선명도',
                    adjustValue: value);
              }),
        ]));
  }
}
