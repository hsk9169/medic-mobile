
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:provider/provider.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/widgets/custom_image_filter.dart';
import 'package:medic_app/widgets/custom_slider.dart';

class ScheduleView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScheduleView();
}

class _ScheduleView extends State<ScheduleView> {
  @override
  void initState() {
    super.initState();
    //_initData();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  void _initData() {}

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        width: context.pWidth,
        child: Column(
          children: [
            Text('준비 중입니다.'),
          ],
        ));
  }
}
