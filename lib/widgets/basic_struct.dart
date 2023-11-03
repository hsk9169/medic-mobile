import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:medic_app/widgets/contained_button.dart';
import 'package:go_router/go_router.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/services/encrypted_storage_service.dart';
import 'package:medic_app/widgets/pop_dialog.dart';

class BasicStruct extends StatefulWidget {
  final Widget childWidget;
  final bool? showPop;
  final bool? showClose;
  final String? bottomTapText;
  final Function? onTapBottom;
  final bool? showAppBar;
  final String? appBarTitle;

  const BasicStruct({
    required this.childWidget,
    this.showPop = true,
    this.showClose = false,
    this.bottomTapText,
    this.onTapBottom,
    this.showAppBar = true,
    this.appBarTitle,
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _BasicStruct();
}

class _BasicStruct extends State<BasicStruct> {
  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    EncryptedStorageService().initStorage();
  }

  Future<bool> _onWillPop() async {
    if (GoRouter.of(context).location == '/' ||
        GoRouter.of(context).location == '/signup') {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                backgroundColor: Colors.white,
                child: Container(
                    padding: EdgeInsets.only(
                      left: context.hPadding,
                      right: context.hPadding,
                      top: context.hPadding * 1.2,
                      bottom: context.hPadding * 1.2,
                    ),
                    width: context.pWidth * 0.75,
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text('알림',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: context.contentsTextSize * 2,
                              fontWeight: FontWeight.bold)),
                      Padding(
                        padding: EdgeInsets.all(context.hPadding * 0.5),
                      ),
                      Text('앱을 종료하시겠습니까?',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: context.contentsTextSize * 1.1,
                              fontWeight: FontWeight.bold)),
                      Padding(
                        padding: EdgeInsets.all(context.hPadding * 0.8),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ContainedButton(
                              onPressed: () => Navigator.pop(context, false),
                              text: '취소',
                              boxWidth: context.pWidth * 0.29,
                              color: Colors.grey[300]!,
                              textSize: context.contentsTextSize,
                              textColor: Colors.black54,
                            ),
                            ContainedButton(
                                onPressed: () => Navigator.pop(context, true),
                                color: Colors.black,
                                text: '확인',
                                boxWidth: context.pWidth * 0.29,
                                textSize: context.contentsTextSize),
                          ])
                    ])));
          }).then((value) {
        return value;
      });
    } else {
      if (context.canPop()) {
        context.pop(context);
      }
      return false;
    }
  }

  void _onTapCloseModal() {
    while (context.canPop()) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading =
        Provider.of<Platform>(context, listen: true).isLoading;
    return Stack(children: [
      WillPopScope(
        child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.5, 0.5],
                colors: [
                  Colors.white,
                  AppColors.mainColor,
                ],
              ),
            ),
            child: SafeArea(
              bottom: widget.bottomTapText != null ? true : false,
              child: Scaffold(
                  backgroundColor: Colors.white,
                  appBar: widget.showAppBar!
                      ? PreferredSize(
                          preferredSize:
                              Size(context.pWidth, context.pHeight * 0.06),
                          child: _renderAppBar(),
                        )
                      : null,
                  body: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: SingleChildScrollView(
                                child: Container(
                                    width: context.pWidth,
                                    padding: EdgeInsets.only(
                                      bottom: context.vPadding * 3,
                                    ),
                                    color: Colors.white,
                                    child: widget.childWidget))),
                        widget.bottomTapText != null
                            ? _bottomButton()
                            : const SizedBox()
                      ])),
            )),
        onWillPop: () => _onWillPop(),
      ),
      isLoading ? _renderLoading() : const SizedBox()
    ]);
  }

  Widget _renderLoading() {
    return Material(
        type: MaterialType.transparency,
        child: Container(
            width: context.pWidth,
            height: context.pHeight,
            color: Colors.black.withOpacity(0.4),
            child: Center(
                child: CupertinoActivityIndicator(
              animating: true,
              radius: context.pWidth * 0.05,
            ))));
  }

  Widget _renderAppBar() {
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border: widget.appBarTitle != null
                ? Border(bottom: BorderSide(color: AppColors.gray01))
                : null),
        child: Stack(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            widget.showPop! && context.canPop()
                ? InkWell(
                    onTap: () => context.pop(),
                    child: Container(
                        height: context.pHeight * 0.05,
                        padding: EdgeInsets.only(
                            left: context.hPadding, right: context.hPadding),
                        child: Icon(Icons.arrow_back_ios,
                            color: Colors.black54,
                            size: context.pWidth * 0.06)))
                : const SizedBox(),
            widget.showClose! && context.canPop()
                ? InkWell(
                    onTap: () => _onTapCloseModal(),
                    child: Container(
                        height: context.pHeight * 0.05,
                        padding: EdgeInsets.only(
                            left: context.hPadding, right: context.hPadding),
                        child: Icon(Icons.close,
                            color: Colors.black54,
                            size: context.pWidth * 0.06)))
                : const SizedBox()
          ]),
          widget.appBarTitle != null
              ? Align(
                  alignment: Alignment.center,
                  child: Text(widget.appBarTitle!,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding,
                          fontWeight: FontWeight.bold)))
              : const SizedBox(),
        ]));
  }

  Widget _bottomButton() {
    return ElevatedButton(
        style: ButtonStyle(
            elevation: MaterialStateProperty.all<double>(0.0),
            fixedSize:
                MaterialStateProperty.all<Size>(Size.fromWidth(context.pWidth)),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                EdgeInsets.all(context.vPadding * 1.5)),
            backgroundColor: MaterialStateProperty.all(AppColors.mainColor),
            overlayColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.grey.withOpacity(0.5);
                }
                return Colors.transparent;
              },
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(borderRadius: BorderRadius.zero))),
        child: Text(widget.bottomTapText!,
            style: TextStyle(
                color: Colors.white,
                fontSize: context.vPadding * 1.5,
                fontWeight: FontWeight.bold)),
        onPressed: () =>
            widget.onTapBottom != null ? widget.onTapBottom!() : null);
  }
}
