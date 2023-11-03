import 'package:flutter/material.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/consts/sizes.dart';

@immutable
class InputForm extends StatefulWidget {
  final String title;
  final String? initData;
  final TextInputType type;
  final bool? isObscure;
  final String? hintText;
  final String? suffixText;
  final Function? onCompleted;
  final Function? onTapSuffix;
  final bool? isEdittable;
  final int? maxLength;
  final bool? suffixTappable;

  const InputForm({
    Key? key,
    required this.title,
    this.initData,
    required this.type,
    this.isObscure,
    this.hintText,
    this.suffixText,
    this.onCompleted,
    this.onTapSuffix,
    this.isEdittable,
    this.maxLength,
    this.suffixTappable = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InputForm();
}

class _InputForm extends State<InputForm> {
  late TextEditingController _textEditingController;

  bool _isTapped = false;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.initData ?? '');
    _textEditingController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  void _onTextChanged() {
    final value = _textEditingController.text;
    widget.onCompleted!(value);
  }

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
        Container(
            width: context.pWidth,
            decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.gray02))),
            child: Row(children: [
              Expanded(
                  flex: 4,
                  child: Container(
                      color: Colors.white,
                      child: TextField(
                          enabled: widget.isEdittable != null ? false : true,
                          maxLength: widget.maxLength,
                          controller: _textEditingController,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(
                                  left: 0, bottom: context.vPadding),
                              hintText: widget.hintText,
                              hintStyle: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.normal),
                              fillColor: Colors.white,
                              filled: true,
                              constraints: BoxConstraints(
                                maxWidth: context.pWidth,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide.none)),
                          keyboardType: widget.type,
                          obscureText: widget.isObscure != null ? true : false,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: context.contentsTextSize,
                          )))),
              widget.suffixText != null
                  ? Expanded(
                      child: Container(
                          alignment: Alignment.centerRight,
                          child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                  onTap: () => widget.onTapSuffix != null
                                      ? widget.onTapSuffix!()
                                      : null,
                                  borderRadius: BorderRadius.circular(
                                      context.hPadding * 0.8),
                                  child: Container(
                                      padding: EdgeInsets.only(
                                        top: context.hPadding * 0.3,
                                        bottom: context.hPadding * 0.3,
                                        left: context.hPadding * 0.5,
                                        right: context.hPadding * 0.5,
                                      ),
                                      decoration: BoxDecoration(
                                          color: widget.suffixTappable!
                                              ? Colors.transparent
                                              : AppColors.mainColor,
                                          border: Border.all(
                                              color: AppColors.mainColor,
                                              width: 1),
                                          borderRadius: BorderRadius.circular(
                                              context.hPadding * 0.8)),
                                      child: Text(
                                          widget.suffixText != null
                                              ? widget.suffixText!
                                              : '',
                                          style: TextStyle(
                                              color: widget.suffixTappable!
                                                  ? AppColors.mainColor
                                                  : Colors.white,
                                              fontSize:
                                                  context.contentsTextSize *
                                                      0.8)))))))
                  : const SizedBox()
            ]))
      ]),
    );
  }
}
