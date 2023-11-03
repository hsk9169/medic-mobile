import 'package:flutter/material.dart';
import 'package:medic_app/consts/sizes.dart';

@immutable
class DataForm extends StatefulWidget {
  final String title;
  final Widget formWidget;

  const DataForm({
    Key? key,
    required this.title,
    required this.formWidget,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DataForm();
}

class _DataForm extends State<DataForm> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.pWidth,
      child: Column(children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(widget.title,
              style: TextStyle(
                  color: Colors.black,
                  fontSize: context.hPadding * 0.8,
                  fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: EdgeInsets.all(context.vPadding * 0.4),
        ),
        widget.formWidget,
      ]),
    );
  }
}
