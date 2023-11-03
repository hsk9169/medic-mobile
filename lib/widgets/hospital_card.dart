import 'package:flutter/material.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/models/api/hospital_data.dart';
import 'package:medic_app/models/external/kakao_address.dart';

class HospitalCard extends StatelessWidget {
  final HospitalData? data;
  final Function onTapSelect;
  HospitalCard({this.data, required this.onTapSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: context.pWidth,
        margin:
            EdgeInsets.only(top: context.vPadding, bottom: context.vPadding),
        child: Row(
          children: [
            Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _basicAddressInfo(context),
                    Padding(
                      padding: EdgeInsets.all(context.vPadding * 0.2),
                    ),
                    _roadAddressInfo(context),
                    Padding(
                      padding: EdgeInsets.all(context.vPadding * 0.2),
                    ),
                  ],
                )),
            Expanded(flex: 1, child: _selectButton(context))
          ],
        ));
  }

  Widget _basicAddressInfo(BuildContext context) {
    return Container(
        alignment: Alignment.centerLeft,
        child: Text(
          data != null ? data!.hospitalName! : '',
          style: TextStyle(
              color: Colors.black,
              fontSize: context.hPadding * 0.7,
              fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ));
  }

  Widget _roadAddressInfo(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(
            top: context.vPadding * 0.2,
            bottom: context.vPadding * 0.2,
            left: context.hPadding * 0.3,
            right: context.hPadding * 0.3,
          ),
          decoration: BoxDecoration(
            color: AppColors.gray01,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text('도로명',
              style: TextStyle(
                  color: AppColors.gray03,
                  fontSize: context.hPadding * 0.5,
                  fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(context.hPadding * 0.2),
        ),
        Expanded(
            child: Text(
          data != null ? data!.basicAddress! : '',
          style: TextStyle(
              color: AppColors.gray03,
              fontSize: context.hPadding * 0.7,
              fontWeight: FontWeight.normal),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ))
      ],
    );
  }

  Widget _selectButton(BuildContext context) {
    return InkWell(
        onTap: () => onTapSelect(data),
        child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(context.hPadding * 0.3),
            decoration: BoxDecoration(
                color: AppColors.mainColor,
                borderRadius: BorderRadius.circular(5)),
            child: Text('선택',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: context.hPadding * 0.8,
                    fontWeight: FontWeight.bold))));
  }
}
