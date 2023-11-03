import 'package:flutter/material.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/models/external/kakao_address.dart';

class RoleToggleBox extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  RoleToggleBox(
      {required this.selected, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(context.hPadding * 1.5),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: selected ? AppColors.mainColor : AppColors.blue02,
            ),
            borderRadius: BorderRadius.circular(5),
            boxShadow: selected
                ? <BoxShadow>[
                    BoxShadow(
                        color: AppColors.mainColor.withOpacity(0.2),
                        blurRadius: 5,
                        spreadRadius: 0.1,
                        offset: Offset(0, 3)),
                  ]
                : null),
        child: Column(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.check_circle_outline,
              size: context.hPadding * 1.3,
              color: selected ? AppColors.mainColor : AppColors.blue02,
            ),
            Padding(padding: EdgeInsets.all(context.vPadding * 0.5)),
            Text(title,
                style: TextStyle(
                  fontSize: context.hPadding,
                  fontWeight: FontWeight.bold,
                  color: selected ? AppColors.mainColor : Colors.black,
                )),
            Padding(padding: EdgeInsets.all(context.vPadding * 0.2)),
            Text(subtitle,
                style: TextStyle(
                  fontSize: context.hPadding * 0.7,
                  fontWeight: FontWeight.normal,
                  color: selected ? AppColors.mainColor : Colors.black,
                ))
          ],
        ));
  }
}
