import 'package:flutter/material.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/widgets/contained_button.dart';

@immutable
class KeywordAdder extends StatefulWidget {
  final List<dynamic> list;

  const KeywordAdder({
    Key? key,
    required this.list,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _KeywordAdder();
}

class _KeywordAdder extends State<KeywordAdder> {
  late ValueNotifier<List<dynamic>> _keywordList;
  late TextEditingController _keywordEditingController;

  @override
  void initState() {
    super.initState();
    _keywordList = ValueNotifier<List<dynamic>>(widget.list);
    _keywordEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _keywordEditingController.dispose();
  }

  void _onAddKeyword(String value) {
    if (!_keywordList.value.contains(value)) {
      _keywordList.value.add(value);
      setState(() {});
    }
  }

  void _onDeleteKeyword(int index) {
    _keywordList.value.removeAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.pWidth,
      child: Column(children: [
        _searchBar(),
        Padding(
          padding: EdgeInsets.all(context.vPadding * 0.4),
        ),
        _keywordListView(),
      ]),
    );
  }

  Widget _searchBar() {
    return Row(children: [
      Expanded(
          flex: 4,
          child: TextField(
              controller: _keywordEditingController,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.go,
              onSubmitted: (val) => _onAddKeyword(val),
              decoration: InputDecoration(
                fillColor: AppColors.blue01,
                contentPadding: EdgeInsets.only(
                    left: context.hPadding, bottom: context.vPadding * 0.5),
                hintText: '키워드 입력',
                hintStyle: const TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.normal),
                filled: true,
                constraints: BoxConstraints(
                  maxWidth: context.pWidth,
                  maxHeight: context.pHeight * 0.05,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(context.hPadding * 0.2),
                ),
              ),
              autofocus: true,
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: Colors.black,
                fontSize: context.contentsTextSize,
              ))),
      Padding(
        padding: EdgeInsets.all(context.hPadding * 0.2),
      ),
      Expanded(
          child: ContainedButton(
        color: AppColors.mainColor,
        text: '추가',
        textSize: context.contentsTextSize,
        textColor: Colors.white,
        onPressed: () => _onAddKeyword(_keywordEditingController.text),
      ))
    ]);
  }

  Widget _keywordListView() {
    return ValueListenableBuilder(
        valueListenable: _keywordList,
        builder: (BuildContext context, List<dynamic> list, _) {
          return SizedBox(
              width: context.pWidth,
              child: Wrap(
                  alignment: WrapAlignment.start,
                  children: List.generate(list.length,
                      (index) => _keywordTag(index, list[index]))));
        });
  }

  Widget _keywordTag(int index, String title) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.gray03, width: 1),
            borderRadius: BorderRadius.circular(context.hPadding * 0.8)),
        padding: EdgeInsets.only(
          left: context.hPadding * 0.6,
          right: context.hPadding * 0.3,
          top: context.vPadding * 0.2,
          bottom: context.vPadding * 0.2,
        ),
        margin: EdgeInsets.only(
          right: context.hPadding * 0.6,
          bottom: context.vPadding * 0.3,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(title,
              style: TextStyle(
                  color: AppColors.gray03, fontSize: context.contentsTextSize)),
          Padding(
              padding: EdgeInsets.only(left: context.hPadding * 0.5),
              child: InkWell(
                  onTap: () => _onDeleteKeyword(index),
                  child: Icon(Icons.close,
                      color: AppColors.gray03, size: context.hPadding * 1.2)))
        ]));
  }
}
