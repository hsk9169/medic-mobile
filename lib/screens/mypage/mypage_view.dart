import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/utils/datetime.dart';
import 'package:medic_app/widgets/list_select_box.dart';

class MypageView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MypageView();
}

class _MypageView extends State<MypageView> {
  late MedicData _testData = MedicData();

  @override
  void initState() {
    super.initState();
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _initData() {
    _testData = MedicData(
      username: '김닥터',
      phone: '01045619502',
      hospitalCode: '부산대학교병원',
      wardCode: '흉부외과',
      position: 'doctor',
      authFlag: false,
    );
  }

  void _onTapEditProfile() {}
  void _onTapLikeList() {}
  void _onTapSignout() {}
  void _onTapDeleteAccount() {}

  @override
  Widget build(BuildContext context) {
    return Container(
        color: AppColors.gray01,
        width: context.pWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _renderProfile(),
            Padding(padding: EdgeInsets.all(context.vPadding * 0.3)),
            _renderAccountInfo(),
            Padding(padding: EdgeInsets.all(context.vPadding * 0.3)),
            _renderAccountControl(),
          ],
        ));
  }

  Widget _renderProfile() {
    //final medicInfo = Provider.of<Session>(context, listen: false).medicData;
    final medicInfo = _testData;
    return Container(
        color: Colors.white,
        width: context.pWidth,
        padding: EdgeInsets.only(
            left: context.hPadding * 2,
            right: context.hPadding * 2,
            top: context.vPadding,
            bottom: context.vPadding),
        child: Row(
          children: [
            Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(medicInfo.username!,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.hPadding,
                            fontWeight: FontWeight.bold)),
                    Padding(padding: EdgeInsets.all(context.vPadding * 0.2)),
                    Text(
                        "의료진(${medicInfo.position! == 'doctor' ? '의사' : '간호사'})",
                        style: TextStyle(
                            color: AppColors.blue03,
                            fontSize: context.hPadding * 0.7)),
                  ],
                )),
            Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("소속병원: ${medicInfo.hospitalCode!}",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.hPadding * 0.7)),
                    Padding(padding: EdgeInsets.all(context.vPadding * 0.2)),
                    Text("소속과: ${medicInfo.wardCode!}",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.hPadding * 0.7)),
                    Padding(padding: EdgeInsets.all(context.vPadding * 0.2)),
                    Text("전화번호: ${medicInfo.phone!}",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.hPadding * 0.7)),
                    Padding(padding: EdgeInsets.all(context.vPadding * 0.2)),
                    Text("인증여부: ${medicInfo.authFlag! ? '인증완료' : '미인증'}",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.hPadding * 0.7)),
                  ],
                )),
          ],
        ));
  }

  Widget _renderAccountInfo() {
    return Container(
        color: Colors.white,
        width: context.pWidth,
        padding: EdgeInsets.only(
            left: context.hPadding * 2,
            right: context.hPadding * 2,
            top: context.vPadding,
            bottom: context.vPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('회원 정보',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: context.hPadding,
                    fontWeight: FontWeight.bold)),
            Padding(
                padding: EdgeInsets.only(
                    top: context.vPadding * 0.5,
                    bottom: context.vPadding * 0.5),
                child: Divider(
                  color: AppColors.blue01,
                  thickness: 1,
                )),
            ListSelectBox(
                title: "프로필 편집", onTapSelect: () => _onTapEditProfile()),
            Padding(
                padding: EdgeInsets.only(
                    top: context.vPadding * 0.5,
                    bottom: context.vPadding * 0.5),
                child: Divider(
                  color: AppColors.blue01,
                  thickness: 1,
                )),
            ListSelectBox(
                title: "즐겨찾기 목록", onTapSelect: () => _onTapLikeList()),
          ],
        ));
  }

  Widget _renderAccountControl() {
    return Container(
        color: Colors.white,
        width: context.pWidth,
        padding: EdgeInsets.only(
            left: context.hPadding * 2,
            right: context.hPadding * 2,
            top: context.vPadding,
            bottom: context.vPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('계정',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: context.hPadding,
                    fontWeight: FontWeight.bold)),
            Padding(
                padding: EdgeInsets.only(
                    top: context.vPadding * 0.5,
                    bottom: context.vPadding * 0.5),
                child: Divider(
                  color: AppColors.blue01,
                  thickness: 1,
                )),
            ListSelectBox(title: "로그아웃", onTapSelect: () => _onTapSignout()),
            Padding(
                padding: EdgeInsets.only(
                    top: context.vPadding * 0.5,
                    bottom: context.vPadding * 0.5),
                child: Divider(
                  color: AppColors.blue01,
                  thickness: 1,
                )),
            ListSelectBox(
                title: "계정 삭제", onTapSelect: () => _onTapDeleteAccount()),
          ],
        ));
  }
}
