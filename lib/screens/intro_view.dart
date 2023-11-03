import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/widgets/basic_struct.dart';
import 'package:medic_app/widgets/contained_button.dart';
import 'package:medic_app/widgets/bordered_button.dart';
import 'package:medic_app/widgets/role_toggle_box.dart';
import 'package:medic_app/services/external/kakao_service.dart';

class IntroView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _IntroView();
}

class _IntroView extends State<IntroView> {
  ValueNotifier<int> _roleSelect = ValueNotifier<int>(-1);

  @override
  void initState() {
    super.initState();
    _initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _initData() {
    KakaoService().getAddressList('대우디오', 1).then((value) {
      if (value.containsKey('err')) {
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
      } else {
        print(value['data'].isEnd);
      }
    });
  }

  void _onTapSelRole(int role) {
    _roleSelect.value = role;
  }

  void _onTapSigninNumber() {
    if (_roleSelect.value == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Align(
              alignment: Alignment.center, child: Text('고객 서비스는 준비 중입니다')),
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(30))),
          margin: EdgeInsets.only(
              left: context.hPadding,
              right: context.hPadding,
              bottom: context.vPadding * 6),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2)));
    } else {
      context.pushNamed('signin', extra: _roleSelect.value);
    }
  }

  void _onTapSigninKakao() {}

  void _onTapSignup() {
    context.pushNamed('signup');
  }

  void _renderRoleSelectAlert() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Align(
            alignment: Alignment.center, child: Text('로그인 계정 유형을 선택해주세요')),
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
    return BasicStruct(
        showPop: false,
        showAppBar: false,
        childWidget: Container(
            margin: EdgeInsets.only(top: context.vPadding * 12),
            padding: EdgeInsets.only(
                left: context.hPadding, right: context.hPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _renderTitle(),
                Padding(padding: EdgeInsets.all(context.vPadding * 1.5)),
                _renderRoleSelect(),
                Padding(padding: EdgeInsets.all(context.vPadding * 1.5)),
                Padding(padding: EdgeInsets.all(context.vPadding * 0.5)),
                BorderedButton(
                  borderColor: AppColors.mainColor,
                  color: Colors.white,
                  text: '휴대폰 번호로 시작하기',
                  textColor: AppColors.mainColor,
                  textSize: context.pWidth * 0.04,
                  prefixImg: Image.asset("asset/icons/phone.png",
                      height: context.vPadding * 1.5),
                  onPressed: () => _roleSelect.value >= 0
                      ? _onTapSigninNumber()
                      : _renderRoleSelectAlert(),
                ),
                Padding(padding: EdgeInsets.all(context.vPadding * 0.3)),
                ContainedButton(
                  color: AppColors.kakaoColor,
                  text: '카카오톡으로 시작하기',
                  textColor: Colors.black,
                  textSize: context.pWidth * 0.04,
                  prefixImg: Image.asset("asset/icons/kakao.png",
                      height: context.vPadding * 1.65),
                  onPressed: () => _roleSelect.value >= 0
                      ? _onTapSigninKakao()
                      : _renderRoleSelectAlert(),
                ),
                Padding(padding: EdgeInsets.all(context.vPadding * 0.3)),
                Align(
                    alignment: Alignment.centerRight,
                    child: InkWell(
                        onTap: () => _onTapSignup(),
                        child: Text('회원가입',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: context.hPadding * 0.75))))
              ],
            )));
  }

  Widget _renderTitle() {
    return SizedBox(
        child: Column(
      children: [
        Text('환부사진,',
            style: TextStyle(
                fontSize: context.pWidth * 0.07, fontWeight: FontWeight.bold)),
        Text('편하게 관리해보세요!',
            style: TextStyle(
                fontSize: context.pWidth * 0.07, fontWeight: FontWeight.bold)),
      ],
    ));
  }

  Widget _renderRoleSelect() {
    return ValueListenableBuilder(
        valueListenable: _roleSelect,
        builder: (BuildContext context, int sel, _) {
          return Row(
            children: [
              Expanded(
                  child: InkWell(
                      onTap: () => _onTapSelRole(1),
                      child: RoleToggleBox(
                          selected: sel == 1,
                          title: '의료진',
                          subtitle: '의사, 간호사'))),
              Padding(
                padding: EdgeInsets.all(context.hPadding * 0.3),
              ),
              Expanded(
                  child: InkWell(
                      onTap: () => _onTapSelRole(0),
                      child: RoleToggleBox(
                          selected: sel == 0, title: '고객', subtitle: '환자'))),
            ],
          );
        });
  }
}
