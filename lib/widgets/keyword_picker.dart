import 'package:flutter/cupertino.dart';
import 'package:medic_app/consts/sizes.dart';

@immutable
class KeywordPicker extends StatefulWidget {
  final List<dynamic> keyword;
  final List<String> keywordList;

  const KeywordPicker({
    Key? key,
    required this.keyword,
    required this.keywordList,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _KeywordPicker();
}

class _KeywordPicker extends State<KeywordPicker> {
  late ValueNotifier<List<dynamic>> _keywordList;
  late TextEditingController _keywordEditingController;

  int _keywordSel = 0;

  @override
  void initState() {
    super.initState();
    _keywordList = ValueNotifier<List<dynamic>>(widget.keyword);
    _keywordEditingController = TextEditingController();
    _initData();
  }

  @override
  void dispose() {
    super.dispose();
    _keywordEditingController.dispose();
  }

  void _initData() {
    if (widget.keyword.isEmpty) {
      widget.keyword.add(widget.keywordList[0]);
    } else {
      _keywordSel = widget.keywordList.indexOf(widget.keyword[0]);
    }
  }

  void _onSelKeyword(int idx) {
    if (widget.keyword.isEmpty) {
      widget.keyword.add(widget.keywordList[idx]);
    } else {
      widget.keyword[0] = widget.keywordList[idx];
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: context.pWidth,
        height: double.infinity,
        child: widget.keywordList.isNotEmpty
            ? CupertinoPicker(
                selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
                  capStartEdge: false,
                  capEndEdge: false,
                ),
                magnification: 1.22,
                squeeze: 1.2,
                itemExtent: 30,
                scrollController: FixedExtentScrollController(
                  initialItem: _keywordSel,
                ),
                onSelectedItemChanged: (int selectedItem) =>
                    _onSelKeyword(selectedItem),
                children: List<Widget>.generate(widget.keywordList.length,
                    (int index) {
                  return Center(child: Text(widget.keywordList[index]));
                }),
              )
            : const SizedBox());
  }
}
