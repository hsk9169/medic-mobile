import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/consts/colors.dart';

@immutable
class DatePicker extends StatefulWidget {
  final List<dynamic> datetime;

  const DatePicker({
    Key? key,
    required this.datetime,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _DatePicker();
}

class _DatePicker extends State<DatePicker> {
  List<String> _yearList = [];
  List<String> _monthList = [];
  ValueNotifier<List<String>> _dayList = ValueNotifier<List<String>>([]);

  int _yearSel = 0;
  int _monthSel = 0;
  int _daySel = 0;
  late DateTime _datetime;
  final _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _datetime =
        widget.datetime.isNotEmpty ? widget.datetime[0] : DateTime.now();
    _initYears();
    _initMonths();
    _initDays();
    _initData();
  }

  void _initYears() {
    _yearSel = _now.year - _datetime.year;
    for (int i = 0; i < 50; i++) {
      _yearList.add((_now.year - i).toString());
    }
  }

  void _initMonths() {
    _monthSel = _datetime.month - 1;
    for (int i = 0; i < 12; i++) {
      _monthList.add((i + 1).toString());
    }
  }

  void _initDays() {
    _daySel = _datetime.day - 1;
    _refreshDayList(_datetime);
  }

  void _initData() {
    if (widget.datetime.isEmpty) {
      widget.datetime.add(DateTime.now());
    } else {
      _yearSel = _yearList.indexOf(widget.datetime[0].year.toString());
      _monthSel = _monthList.indexOf(widget.datetime[0].month.toString());
      _daySel = _dayList.value.indexOf(widget.datetime[0].day.toString());
      _datetime = DateTime(int.parse(_yearList[_yearSel]),
          int.parse(_monthList[_monthSel]), int.parse(_dayList.value[_daySel]));
    }
  }

  void _refreshDayList(DateTime datetime) {
    _dayList.value = [];
    final lastDay = DateTime(datetime.year, datetime.month + 1, 0).day;
    for (int i = 0; i < lastDay; i++) {
      _dayList.value.add((i + 1).toString());
    }
    setState(() {});
  }

  void _onSelYear(int idx) {
    _datetime =
        DateTime(int.parse(_yearList[idx]), _datetime.month, _datetime.day);
    if (widget.datetime.isEmpty) {
      widget.datetime.add(_datetime);
    } else {
      widget.datetime[0] = _datetime;
    }
    _refreshDayList(_datetime);
  }

  void _onSelMonth(int idx) {
    _datetime =
        DateTime(_datetime.year, int.parse(_monthList[idx]), _datetime.day);
    if (widget.datetime.isEmpty) {
      widget.datetime.add(_datetime);
    } else {
      widget.datetime[0] = _datetime;
    }
    _refreshDayList(_datetime);
  }

  void _onSelDay(int idx) {
    _datetime = DateTime(
      _datetime.year,
      _datetime.month,
      int.parse(_dayList.value[idx]),
    );
    if (widget.datetime.isEmpty) {
      widget.datetime.add(_datetime);
    } else {
      widget.datetime[0] = _datetime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Expanded(
          child: CupertinoPicker(
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
          capStartEdge: false,
          capEndEdge: false,
        ),
        magnification: 1.22,
        squeeze: 1.2,
        itemExtent: 30,
        scrollController: FixedExtentScrollController(
          initialItem: _yearSel,
        ),
        onSelectedItemChanged: (int selectedItem) => _onSelYear(selectedItem),
        children: List<Widget>.generate(_yearList.length, (int index) {
          return Center(child: Text(_yearList[index]));
        }),
      )),
      Expanded(
          child: CupertinoPicker(
        selectionOverlay: const CupertinoPickerDefaultSelectionOverlay(
          capStartEdge: false,
          capEndEdge: false,
        ),
        magnification: 1.22,
        squeeze: 1.2,
        itemExtent: 30,
        scrollController: FixedExtentScrollController(
          initialItem: _monthSel,
        ),
        onSelectedItemChanged: (int selectedItem) => _onSelMonth(selectedItem),
        children: List<Widget>.generate(_monthList.length, (int index) {
          return Center(child: Text(_monthList[index]));
        }),
      )),
      Expanded(
          child: ValueListenableBuilder(
              valueListenable: _dayList,
              builder: (BuildContext context, List<String> dayList, _) {
                return CupertinoPicker(
                  selectionOverlay:
                      const CupertinoPickerDefaultSelectionOverlay(
                    capStartEdge: false,
                    capEndEdge: false,
                  ),
                  magnification: 1.22,
                  squeeze: 1.2,
                  itemExtent: 30,
                  scrollController: FixedExtentScrollController(
                    initialItem: _daySel,
                  ),
                  onSelectedItemChanged: (int selectedItem) =>
                      _onSelDay(selectedItem),
                  children: List<Widget>.generate(dayList.length, (int index) {
                    return Center(child: Text(dayList[index]));
                  }),
                );
              })),
    ]);
  }
}
