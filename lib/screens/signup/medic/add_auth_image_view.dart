import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/widgets/basic_struct.dart';
import 'package:medic_app/widgets/contained_button.dart';
import 'package:medic_app/widgets/input_form.dart';

class AddAuthImageView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddAuthImageView();
}

class _AddAuthImageView extends State<AddAuthImageView> {
  late double _imageSize;
  bool _isTakingPic = false;

  late CameraController _cameraController;
  late Future<void> _initializeCameraControllerFuture;

  @override
  void initState() {
    super.initState();
    _initData();
    final camera = Provider.of<Platform>(context, listen: false).camera;
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
    );
    if (camera != null) {
      _initializeCameraControllerFuture = _cameraController.initialize();
    } else {
      _initializeCameraControllerFuture = Future.value(null);
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController.dispose();
  }

  void _initData() {}

  void _onTapTakingPicture() async {
    setState(() => _isTakingPic = true);
    try {
      await _initializeCameraControllerFuture;
      await _cameraController.takePicture().then((picture) {
        final image = File(picture.path);
        context.pop(image as File);
      });
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

  void _onTapGetImageFromAlbum() {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    _getImageFromAlbum().then((value) {
      if (value != null) {
        context.pop(value as File);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Align(
                alignment: Alignment.center, child: Text("이미지 로드에 실패했습니다.")),
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
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  Future<dynamic> _getImageFromAlbum() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      final File file = File(image.path);
      return file;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    _imageSize = context.pWidth - context.hPadding * 2;
    return BasicStruct(
        appBarTitle: '사진 촬영/첨부',
        childWidget: Container(
            color: Colors.white,
            width: context.pWidth,
            margin: EdgeInsets.only(top: context.vPadding),
            padding: EdgeInsets.only(
                left: context.hPadding, right: context.hPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _renderCameraView(),
                Padding(padding: EdgeInsets.all(context.vPadding)),
                ContainedButton(
                  onPressed: () => _onTapGetImageFromAlbum(),
                  color: AppColors.mainColor,
                  text: '사진 첨부하기',
                  textColor: Colors.white,
                  textSize: context.contentsTextSize,
                  textWeight: FontWeight.bold,
                )
              ],
            )));
  }

  Widget _renderCameraView() {
    return Container(
        width: _imageSize,
        height: _imageSize,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.hPadding)),
        child: _renderCamera());
  }

  Widget _renderCamera() {
    return FutureBuilder(
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
          print(snapshot.connectionState);
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
}
