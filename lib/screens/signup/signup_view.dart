import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:provider/provider.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/widgets/basic_struct.dart';
import 'package:medic_app/widgets/contained_button.dart';

class SignupView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignupView();
}

class _SignupView extends State<SignupView> {
  @override
  void initState() {
    super.initState();
    //_initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _onTapCustomer() {
    context.pushNamed('selMethod', extra: 0);
  }

  void _onTapMedic() {
    context.pushNamed('selMethod', extra: 1);
  }

  @override
  Widget build(BuildContext context) {
    return BasicStruct(
        childWidget: Container(
            margin: EdgeInsets.only(top: context.vPadding * 12),
            padding: EdgeInsets.only(
                left: context.hPadding, right: context.hPadding),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              _renderStartMedic(),
              Padding(padding: EdgeInsets.all(context.vPadding * 0.6)),
              _renderStartCustomer(),
            ])));
  }

  Widget _renderStartMedic() {
    return InkWell(
        onTap: () => _onTapMedic(),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: null,
                borderRadius: BorderRadius.circular(context.hPadding * 0.5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: AppColors.blue01, blurRadius: 5, spreadRadius: 3),
                ]),
            padding: EdgeInsets.only(
              top: context.vPadding * 2,
              bottom: context.vPadding * 2,
              left: context.hPadding,
              right: context.hPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 2,
                    child: Image.asset('asset/icons/doctor_3d.png',
                        height: context.vPadding * 8, fit: BoxFit.fitHeight)),
                Expanded(
                    flex: 3,
                    child: Padding(
                        padding: EdgeInsets.only(left: context.hPadding),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('의료진',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: context.pWidth * 0.05,
                                      fontWeight: FontWeight.bold)),
                              Text('의사, 간호사',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: context.pWidth * 0.04,
                                      fontWeight: FontWeight.normal)),
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

  Widget _renderStartCustomer() {
    return InkWell(
        onTap: () => _onTapCustomer(),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                border: null,
                borderRadius: BorderRadius.circular(context.hPadding * 0.5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: AppColors.blue01, blurRadius: 5, spreadRadius: 3),
                ]),
            padding: EdgeInsets.only(
              top: context.vPadding * 2,
              bottom: context.vPadding * 2,
              left: context.hPadding,
              right: context.hPadding,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    flex: 2,
                    child: Image.asset('asset/icons/medicine.png',
                        height: context.vPadding * 8, fit: BoxFit.fitWidth)),
                Expanded(
                    flex: 3,
                    child: Padding(
                        padding: EdgeInsets.only(left: context.hPadding),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('고객',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: context.pWidth * 0.05,
                                      fontWeight: FontWeight.bold)),
                              Text('환자',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: context.pWidth * 0.04,
                                      fontWeight: FontWeight.normal)),
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
}
