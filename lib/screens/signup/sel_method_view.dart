import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/widgets/basic_struct.dart';
import 'package:medic_app/widgets/contained_button.dart';

class SelMethodView extends StatefulWidget {
  int userDiv;
  SelMethodView({required this.userDiv});
  @override
  State<StatefulWidget> createState() => _SelMethodView();
}

class _SelMethodView extends State<SelMethodView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _onTapKakao() {}

  void _onTapNumber() {
    context.pushNamed(widget.userDiv == 0 ? 'customerSignup' : 'medicSignup',
        queryParameters: {
          'username': '',
          'birthDate': '',
          'phone': '',
        });
  }

  @override
  Widget build(BuildContext context) {
    return BasicStruct(
        childWidget: Container(
            margin: EdgeInsets.only(top: context.vPadding * 12),
            padding: EdgeInsets.only(
                left: context.hPadding, right: context.hPadding),
            width: context.pWidth,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              _renderStartPhone(),
              Padding(padding: EdgeInsets.all(context.vPadding * 0.6)),
              _renderStartKakao(),
            ])));
  }

  Widget _renderStartPhone() {
    return InkWell(
        onTap: () => _onTapNumber(),
        child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.mainColor),
              borderRadius: BorderRadius.circular(context.hPadding * 0.5),
            ),
            padding: EdgeInsets.only(
              top: context.vPadding * 2,
              bottom: context.vPadding * 2,
              right: context.hPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 2,
                    child: Image.asset('asset/icons/phone_3d.png',
                        height: context.vPadding * 8, fit: BoxFit.fitWidth)),
                Expanded(
                    flex: 4,
                    child: Padding(
                        padding: EdgeInsets.only(left: context.hPadding),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('휴대폰 번호로',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: context.pWidth * 0.05,
                                      fontWeight: FontWeight.bold)),
                              Text('시작하기',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: context.pWidth * 0.05,
                                      fontWeight: FontWeight.bold)),
                            ]))),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(context.hPadding * 0.5),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.mainColor),
                        child: Icon(Icons.arrow_forward_ios_sharp,
                            color: Colors.white, size: context.pWidth * 0.06)))
              ],
            )));
  }

  Widget _renderStartKakao() {
    return InkWell(
        onTap: () => _onTapKakao(),
        child: Container(
            decoration: BoxDecoration(
              color: AppColors.kakaoColor,
              border: Border.all(color: AppColors.kakaoColor),
              borderRadius: BorderRadius.circular(context.hPadding * 0.5),
            ),
            padding: EdgeInsets.only(
              top: context.vPadding * 2,
              bottom: context.vPadding * 2,
              right: context.hPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 2,
                    child: Stack(alignment: Alignment.center, children: [
                      Image.asset('asset/icons/bubble.png',
                          width: context.hPadding * 16,
                          height: context.vPadding * 8,
                          fit: BoxFit.fitWidth),
                      Image.asset('asset/icons/kakao.png',
                          width: context.hPadding * 2.5,
                          height: context.vPadding * 5,
                          fit: BoxFit.fitWidth),
                    ])),
                Expanded(
                    flex: 4,
                    child: Padding(
                        padding: EdgeInsets.only(left: context.hPadding),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('카카오톡으로',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: context.pWidth * 0.05,
                                      fontWeight: FontWeight.bold)),
                              Text('시작하기',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: context.pWidth * 0.05,
                                      fontWeight: FontWeight.bold)),
                            ]))),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(context.hPadding * 0.5),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                        child: Icon(Icons.arrow_forward_ios_sharp,
                            color: AppColors.gray03,
                            size: context.pWidth * 0.06)))
              ],
            )));
  }
}
