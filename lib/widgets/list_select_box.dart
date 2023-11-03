import 'package:flutter/material.dart';
import 'package:medic_app/consts/sizes.dart';

class ListSelectBox extends StatelessWidget {
  final String title;
  final Function? onTapSelect;
  ListSelectBox({required this.title, required this.onTapSelect});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTapSelect != null ? onTapSelect!() : null,
        child: SizedBox(
            width: context.pWidth,
            child: Row(
              children: [
                Expanded(
                    flex: 9,
                    child: Text(title,
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: context.hPadding * 0.9))),
                Expanded(
                    flex: 1,
                    child: Icon(Icons.arrow_forward_ios,
                        color: Colors.black, size: context.hPadding * 0.8))
              ],
            )));
  }
}
