import 'dart:io';
import 'package:flutter/material.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/utils/filter.dart';

class CustomImageFilter extends StatefulWidget {
  final double hue;
  final double brightness;
  final double saturation;
  final File image;
  const CustomImageFilter({
    required this.hue,
    required this.brightness,
    required this.saturation,
    required this.image,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomImageFilter> createState() => _CustomImageFilter();
}

class _CustomImageFilter extends State<CustomImageFilter> {
  late double _imageSize;

  @override
  Widget build(BuildContext context) {
    _imageSize = context.pWidth - context.hPadding * 2;
    return ColorFiltered(
        colorFilter: ColorFilter.matrix(
            ColorFilterGenerator.brightnessAdjustMatrix(widget.brightness)),
        child: ColorFiltered(
            colorFilter: ColorFilter.matrix(
                ColorFilterGenerator.saturationAdjustMatrix(widget.saturation)),
            child: ColorFiltered(
                colorFilter: ColorFilter.matrix(
                    ColorFilterGenerator.hueAdjustMatrix(widget.hue)),
                child: Container(
                  width: _imageSize,
                  height: _imageSize,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(widget.image), fit: BoxFit.cover),
                      borderRadius: BorderRadius.circular(context.hPadding)),
                ))));
  }
}
