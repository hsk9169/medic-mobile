import 'package:flutter/material.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/widgets/contained_button.dart';

@immutable
class PopDialog extends StatelessWidget {
  final AssetImage? image;
  final Widget textWidget;
  final Color? imageColor;
  final Function onPressed;

  const PopDialog({
    Key? key,
    this.image,
    required this.textWidget,
    this.imageColor,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.white,
        child: Container(
            padding: EdgeInsets.all(context.hPadding),
            width: context.pWidth * 0.7,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              image != null
                  ? Container(
                      width: context.hPadding * 2.5,
                      height: context.hPadding * 2.5,
                      padding: EdgeInsets.only(bottom: context.hPadding * 0.2),
                      child: Image(
                          color: imageColor!,
                          image: image!,
                          width: context.hPadding * 2.5,
                          height: context.hPadding * 2.5))
                  : const SizedBox(),
              textWidget,
              Padding(
                padding: EdgeInsets.all(context.hPadding * 0.5),
              ),
              ContainedButton(
                  onPressed: () => onPressed(),
                  color: Colors.black,
                  text: '확인',
                  boxWidth: context.pWidth,
                  textSize: context.contentsTextSize)
            ])));
  }
}
