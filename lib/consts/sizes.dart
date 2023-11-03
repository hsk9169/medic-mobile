import 'package:flutter/material.dart';

extension MediaQueryValues on BuildContext {
  double get pWidth => MediaQuery.of(this).size.width;
  double get pHeight => MediaQuery.of(this).size.height;
  double get hPadding => pWidth * 0.05;
  double get vPadding => pHeight * 0.015;
  double get contentsTextSize => pWidth * 0.04;
  double get contentsIconSize => pHeight * 0.03;
  FontWeight get normalWeight => FontWeight.w300;
  FontWeight get boldWeight => FontWeight.w500;
}
