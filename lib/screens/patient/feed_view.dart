import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:provider/provider.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/widgets/basic_struct.dart';
import 'package:medic_app/widgets/profile_card_simple.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/utils/datetime.dart';
import 'package:medic_app/services/api/s3/feed_service.dart';

class PatientFeedView extends StatefulWidget {
  final PatientDataRes patientData;
  final FeedData feedData;
  const PatientFeedView(
      {required this.patientData, required this.feedData, Key? key})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _PatientFeedView();
}

class _PatientFeedView extends State<PatientFeedView> {
  ValueNotifier<int> _imageIndex = ValueNotifier<int>(0);
  late Future<dynamic> _feedImageListFuture;

  @override
  void initState() {
    super.initState();
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _initData() {
    _feedImageListFuture = _getFeedImageList();
  }

  Future<dynamic> _getFeedImageList() {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    return FeedService()
        .getFeedImageList(widget.patientData.id!, widget.feedData.imageUrls!)
        .then((value) {
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
        return null;
      } else {
        return value['data'];
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _onImageChanged(int index) {
    _imageIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return BasicStruct(
        showPop: true,
        showClose: true,
        appBarTitle: '게시물',
        childWidget: Container(
            color: Colors.white,
            width: context.pWidth,
            margin: EdgeInsets.only(bottom: context.vPadding),
            child: Column(children: [
              _renderProfile(),
              Padding(padding: EdgeInsets.all(context.vPadding * 0.5)),
              _renderFeedDate(),
              Padding(padding: EdgeInsets.all(context.vPadding * 0.5)),
              _renderImages(),
              Padding(padding: EdgeInsets.all(context.vPadding * 0.5)),
              _renderContents(),
            ])));
  }

  Widget _renderProfile() {
    return Container(
        padding: EdgeInsets.only(
          left: context.hPadding,
          right: context.hPadding,
          top: context.vPadding,
          bottom: context.vPadding,
        ),
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.gray01))),
        child: ProfileCardSimple(patient: widget.patientData));
  }

  Widget _renderFeedDate() {
    final date = Datetime()
        .getSimpleDateFromServerDatetime(widget.feedData.createdDate!);
    return Container(
        padding: EdgeInsets.only(
          left: context.hPadding,
        ),
        alignment: Alignment.centerLeft,
        child: Text(date,
            style: TextStyle(
                color: AppColors.blue03, fontSize: context.hPadding * 0.8)));
  }

  Widget _renderImages() {
    final imgSize = context.pWidth - context.hPadding * 2;
    return FutureBuilder(
        future: _feedImageListFuture,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            final imgList = snapshot.data!;
            return ValueListenableBuilder(
                valueListenable: _imageIndex,
                builder: (BuildContext context, int index, _) {
                  return Container(
                    width: imgSize,
                    height: imgSize,
                    color: Colors.white,
                    child: Stack(children: [
                      CarouselSlider(
                          options: CarouselOptions(
                              enableInfiniteScroll: false,
                              height: imgSize,
                              viewportFraction: 1.0,
                              onPageChanged: (index, reason) =>
                                  _onImageChanged(index)),
                          items: List.generate(
                            imgList.length,
                            (index) => Container(
                                color: Colors.white,
                                width: imgSize,
                                height: imgSize,
                                child: Image.memory(
                                    fit: BoxFit.fitHeight,
                                    base64Decode(imgList[index]))),
                          ).toList()),
                      Align(
                          alignment: Alignment.bottomCenter,
                          child: DotsIndicator(
                            dotsCount: imgList.length,
                            position: index,
                            decorator: DotsDecorator(
                              color: AppColors.blue01,
                              activeColor: AppColors.blue03,
                            ),
                          ))
                    ]),
                  );
                });
          } else {
            return Container(
                width: imgSize,
                height: imgSize,
                color: AppColors.blue01,
                child: Icon(Icons.photo,
                    color: Colors.white, size: context.pWidth * 0.3));
          }
        });
  }

  Widget _renderContents() {
    return Container(
        padding: EdgeInsets.only(
          left: context.hPadding,
          right: context.hPadding,
        ),
        width: context.pWidth,
        margin: EdgeInsets.only(top: context.vPadding),
        child: Text(widget.feedData.postContent!,
            style: TextStyle(fontSize: context.hPadding * 0.85)));
  }
}
