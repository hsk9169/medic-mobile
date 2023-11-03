import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:animations/animations.dart';
import 'package:go_router/go_router.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/screens/screens.dart';
import 'package:provider/provider.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/widgets/pop_dialog.dart';

const List<String> titleList = [
  '내 환자 리스트',
  '관리',
  '팔찌 인식',
  '스케줄',
  '내 정보',
];

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeView();
}

class _HomeView extends State<HomeView> {
  int _selected = 0;
  ValueNotifier<String> _appBarText = ValueNotifier<String>('홈');

  @override
  void initState() {
    super.initState();
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _initData() {
    print(Provider.of<Session>(context, listen: false).userData.toJson());
  }

  Widget? _bodyWidget(int _index) {
    switch (_index) {
      case 0:
        return MainView();
      case 1:
        return ManageView();
      case 3:
        return ScheduleView();
      case 4:
        return MypageView();
      default:
        break;
    }
  }

  void _onItemTapped(int sel) {
    if (sel == 2) {
      _renderScanView();
    } else {
      _appBarText.value = titleList[sel];
      _selected = sel;
    }
    setState(() {});
  }

  void _renderScanView() {
    showModalBottomSheet(
        useSafeArea: true,
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.white,
        barrierColor: Colors.white,
        builder: (BuildContext context) {
          return ScanView();
        });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading =
        Provider.of<Platform>(context, listen: true).isLoading;
    bool isAuthorized =
        Provider.of<Session>(context, listen: true).isAuthorized;
    _showErrorMsg(isAuthorized);
    return Stack(children: [
      Container(
          color: Colors.white,
          child: SafeArea(
              bottom: false,
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size(context.pWidth, context.pHeight * 0.06),
                  child: _renderAppBar(),
                ),
                body: (PageTransitionSwitcher(
                    transitionBuilder: (
                      child,
                      animation,
                      secondaryAnimation,
                    ) {
                      return SharedAxisTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          transitionType: SharedAxisTransitionType.horizontal,
                          child: child);
                    },
                    child: _bodyWidget(_selected))),
                bottomNavigationBar: Container(
                    height: context.pHeight * 0.12,
                    decoration: BoxDecoration(boxShadow: <BoxShadow>[
                      BoxShadow(color: AppColors.gray02, blurRadius: 20),
                    ]),
                    child: //BottomAppBar()
                        BottomNavigationBar(
                      backgroundColor: Colors.white,
                      items: <BottomNavigationBarItem>[
                        BottomNavigationBarItem(
                          icon: Container(
                              margin: EdgeInsets.only(
                                  bottom: context.vPadding * 0.4),
                              child: Image(
                                  fit: BoxFit.fitHeight,
                                  width: context.hPadding * 1.1,
                                  height: context.hPadding * 1.1,
                                  image: _selected == 0
                                      ? AssetImage('asset/icons/home_on.png')
                                      : AssetImage(
                                          'asset/icons/home_off.png'))),
                          label: '홈',
                        ),
                        BottomNavigationBarItem(
                          icon: Container(
                              margin: EdgeInsets.only(
                                  bottom: context.vPadding * 0.4),
                              child: Image(
                                  width: context.hPadding * 1.1,
                                  height: context.hPadding * 1.1,
                                  image: _selected == 1
                                      ? AssetImage('asset/icons/manage_on.png')
                                      : AssetImage(
                                          'asset/icons/manage_off.png'))),
                          label: '관리',
                        ),
                        BottomNavigationBarItem(
                            icon: Container(
                                margin: EdgeInsets.only(
                                    bottom: context.vPadding * 0.2),
                                child: Image(
                                    width: context.hPadding * 1.6,
                                    height: context.hPadding * 1.6,
                                    image: AssetImage('asset/icons/scan.png'))),
                            label: '스캔'),
                        BottomNavigationBarItem(
                          icon: Container(
                              margin: EdgeInsets.only(
                                  bottom: context.vPadding * 0.4),
                              child: Image(
                                  width: context.hPadding * 1.1,
                                  height: context.hPadding * 1.1,
                                  image: _selected == 3
                                      ? AssetImage(
                                          'asset/icons/schedule_on.png')
                                      : AssetImage(
                                          'asset/icons/schedule_off.png'))),
                          label: '스케줄',
                        ),
                        BottomNavigationBarItem(
                          icon: Container(
                              margin: EdgeInsets.only(
                                  bottom: context.vPadding * 0.4),
                              child: Image(
                                  width: context.hPadding * 1.1,
                                  height: context.hPadding * 1.1,
                                  image: _selected == 4
                                      ? AssetImage('asset/icons/mypage_on.png')
                                      : AssetImage(
                                          'asset/icons/mypage_off.png'))),
                          label: '내 정보',
                        ),
                      ],
                      currentIndex: _selected,
                      onTap: _onItemTapped,
                      type: BottomNavigationBarType.fixed,
                      selectedLabelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.6,
                          fontWeight: FontWeight.bold),
                      unselectedLabelStyle: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding * 0.6,
                          fontWeight: FontWeight.normal),
                      elevation: 50,
                    )),
              ))),
      isLoading ? _renderLoading() : const SizedBox()
    ]);
  }

  Widget _renderAppBar() {
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.gray01))),
        child: Align(
            alignment: Alignment.center,
            child: ValueListenableBuilder(
                valueListenable: _appBarText,
                builder: (BuildContext context, String value, _) {
                  return Text(value,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.hPadding,
                          fontWeight: FontWeight.bold));
                })));
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

  void _showErrorMsg(bool isError) {
    Future.delayed(Duration.zero, () async {
      if (!isError) {
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return PopDialog(
                textWidget: Column(children: [
                  Text('세션이 만료되었습니다',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: context.contentsTextSize,
                          fontWeight: FontWeight.bold)),
                  Padding(
                    padding: EdgeInsets.all(context.vPadding * 0.1),
                  ),
                  Text('다시 로그인해주세요.',
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
    });
  }
}
