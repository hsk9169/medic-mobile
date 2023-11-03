import 'package:flutter/material.dart';
import 'package:medic_app/consts/sizes.dart';

@immutable
class ContainedButton extends StatelessWidget {
  final Function? onPressed;
  final Color color;
  final String text;
  final double? boxWidth;
  final double? textSize;
  final Color? textColor;
  final FontWeight? textWeight;
  final Color? borderColor;
  final Image? prefixImg;

  const ContainedButton({
    Key? key,
    this.onPressed,
    required this.color,
    required this.text,
    this.boxWidth,
    this.textSize,
    this.textColor,
    this.textWeight,
    this.borderColor,
    this.prefixImg,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.all<double>(0.0),
          fixedSize: boxWidth == null
              ? MaterialStateProperty.all<Size>(Size.fromWidth(context.pWidth))
              : MaterialStateProperty.all<Size>(Size.fromWidth(boxWidth!)),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.all(context.vPadding)),
          backgroundColor: onPressed != null
              ? MaterialStateProperty.all(color)
              : MaterialStateProperty.all(Colors.grey),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.pWidth * 0.01),
            ),
          ),
          side: MaterialStateProperty.all<BorderSide>(
              BorderSide(color: borderColor ?? Colors.transparent)),
          overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) {
                return Colors.grey.withOpacity(0.5);
              }
              return Colors.transparent;
            },
          ),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          prefixImg ?? const SizedBox(),
          prefixImg != null
              ? Padding(
                  padding: EdgeInsets.all(context.hPadding * 0.3),
                )
              : const SizedBox(),
          Text(text,
              style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: textSize ?? context.contentsTextSize * 1.3,
                  fontWeight: textWeight ?? FontWeight.normal)),
        ]),
        onPressed: () => onPressed != null ? onPressed!() : null);
  }
}
