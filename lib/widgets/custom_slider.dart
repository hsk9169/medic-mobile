import 'package:flutter/material.dart';
import 'package:medic_app/consts/sizes.dart';

class CustomSlider extends StatefulWidget {
  double adjustValue;
  String title;
  Function onChanged;
  CustomSlider(
      {required this.adjustValue,
      required this.title,
      required this.onChanged,
      Key? key})
      : super(key: key);

  @override
  State<CustomSlider> createState() => _CustomSlider();
}

class _CustomSlider extends State<CustomSlider> {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left: context.hPadding),
          child: Text(widget.title)),
      Slider(
          value: widget.adjustValue,
          min: -1.0,
          max: 1.0,
          divisions: 200,
          onChanged: (double value) => widget.onChanged(value))
    ]);
  }
}
