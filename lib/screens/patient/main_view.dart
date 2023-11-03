import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:provider/provider.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/widgets/basic_struct.dart';
import 'package:medic_app/widgets/profile_card_simple.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/services/api/s3/feed_service.dart';

class PatientMainView extends StatefulWidget {
  final PatientDataRes patientData;
  const PatientMainView({required this.patientData, Key? key})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _PatientMainView();
}

class _PatientMainView extends State<PatientMainView> {
  List<FeedData> _feedList = [];

  FeedService _feedService = FeedService();
  late Future<dynamic> _feedListFuture;

  @override
  void initState() {
    super.initState();
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _initData() {
    _feedListFuture = _getFeedList();
  }

  Future<dynamic> _getFeedList() {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    return _feedService.getFeedList(widget.patientData.id!).then((value) {
      if (value.containsKey('err')) {
        if (value['err'] == _feedService.unauthorizedFlag) {
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
        _feedList = value['data'].feedDataList;
        return value['data'];
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _onTapPicture(int index) {
    context.pushNamed('feedPage', extra: {
      'patientData': widget.patientData,
      'feedData': _feedList[index]
    });
  }

  @override
  Widget build(BuildContext context) {
    return BasicStruct(
        showPop: false,
        showClose: true,
        appBarTitle: '환자 일지',
        childWidget: Container(
            color: Colors.white,
            width: context.pWidth,
            margin: EdgeInsets.only(bottom: context.vPadding),
            child: Column(children: [
              _renderProfile(),
              Padding(padding: EdgeInsets.all(context.vPadding * 0.5)),
              _renderImageList(),
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

  Widget _renderImageList() {
    final imgSize =
        (context.pWidth - (context.hPadding * 2) - (context.hPadding / 2)) / 3;
    return FutureBuilder(
        future: _feedListFuture,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            final List<FeedData> feedList = snapshot.data!.feedDataList;
            return feedList.isNotEmpty
                ? Container(
                    width: context.pWidth,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.only(
                      left: context.hPadding,
                      right: context.hPadding,
                    ),
                    child: Wrap(
                        alignment: WrapAlignment.start,
                        children: List.generate(
                            feedList.length,
                            (index) => InkWell(
                                onTap: () => _onTapPicture(index),
                                child: Container(
                                  color: AppColors.blue01,
                                  margin: EdgeInsets.only(
                                      bottom: context.hPadding / 8,
                                      right: context.hPadding / 8),
                                  child: feedList[index]
                                          .thumbnailImage!
                                          .isNotEmpty
                                      ? Image.memory(
                                          width: imgSize,
                                          height: imgSize,
                                          fit: BoxFit.fitHeight,
                                          base64Decode(
                                              feedList[index].thumbnailImage!))
                                      : Container(
                                          width: imgSize,
                                          height: imgSize,
                                          color: AppColors.blue01,
                                          child: Icon(
                                            Icons.insert_photo_rounded,
                                            size: context.hPadding * 1.5,
                                            color: AppColors.blue03,
                                          )),
                                )))))
                : Container(
                    width: context.pWidth,
                    alignment: Alignment.center,
                    child: Text('피드 없음'));
          } else {
            return Container(
                width: context.pWidth,
                alignment: Alignment.center,
                child: Text('피드 불러오는 중...'));
          }
        });
  }
}
