import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/widgets/profile_card_detail.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/services/api/basic/patient_service.dart';
import 'package:medic_app/services/api/basic/medic_service.dart';
import 'package:medic_app/widgets/keyword_picker.dart';
import 'package:medic_app/widgets/keyword_adder.dart';
import 'package:medic_app/widgets/date_picker.dart';
import 'package:medic_app/utils/datetime.dart';

class MainView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainView();
}

class _MainView extends State<MainView> with TickerProviderStateMixin {
  late AnimationController _bottomModalController;

  late TextEditingController _searchTextEditingController;

  ValueNotifier<String> _searchText = ValueNotifier<String>('');
  ValueNotifier<String> _filter = ValueNotifier<String>('');
  ValueNotifier<bool> _modalUp = ValueNotifier<bool>(false);

  Map<String, List<dynamic>> _filters = {
    '담당의': [],
    '간호사': [],
    '촬영일자': [],
    '병동': [],
  };

  PatientService _patientService = PatientService();
  MedicService _medicService = MedicService();
  late Future<dynamic> _patientListFuture;
  late Future<dynamic> _doctorFilterListFuture;
  late Future<dynamic> _nurseFilterListFuture;
  List<String> _doctorFilterList = [];
  List<String> _nurseFilterList = [];

  PatientReqFilter _reqFilters = PatientReqFilter(hospitalCode: '');

  @override
  void initState() {
    super.initState();
    _initData();
    _bottomModalController = BottomSheet.createAnimationController(this);
    _bottomModalController.duration = Duration(milliseconds: 200);
    _searchTextEditingController =
        TextEditingController(text: _searchText.value);
    _searchTextEditingController.addListener(_onSearchTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      Provider.of<Platform>(context, listen: false).isLoading = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchTextEditingController.dispose();
  }

  void _initData() async {
    _reqFilters.hospitalCode =
        Provider.of<Session>(context, listen: false).medicData.hospitalCode ??
            '';
    _doctorFilterListFuture = _getFilterList('doctor');
    _nurseFilterListFuture = _getFilterList('nurse');
    _patientListFuture = _getPatientList();
  }

  Future<dynamic> _getPatientList() {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    return _patientService
        .getPatientListByHospitalAndFilters(_reqFilters)
        .then((value) {
      if (value.containsKey('err')) {
        if (value['err'] == _patientService.unauthorizedFlag) {
          Provider.of<Session>(context, listen: false).isAuthorized = false;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Align(alignment: Alignment.center, child: Text(value['err'])),
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              margin: EdgeInsets.only(
                  left: context.hPadding,
                  right: context.hPadding,
                  bottom: context.vPadding * 6),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2)));
          return null;
        }
      } else {
        return value['data'];
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _refreshPatientList() {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    _patientListFuture = _getPatientList();
    //setState(() {});
  }

  Future<dynamic> _getFilterList(String position) {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    final sessionProvider = Provider.of<Session>(context, listen: false);
    return _medicService
        .getMedicList(sessionProvider.medicData.hospitalCode!, position)
        .then((value) {
      if (value.containsKey('data')) {
        if (position == 'doctor') {
          _doctorFilterList = value['data'] as List<String>;
        } else if (position == 'nurse') {
          _nurseFilterList = value['data'] as List<String>;
        }
        return value['data'];
      } else {
        if (value.containsKey('err')) {
          if (value['err'] == _patientService.unauthorizedFlag) {
            Provider.of<Session>(context, listen: false).isAuthorized = false;
          }
        }
        return null;
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  void _onSearchTextChanged() {
    _searchText.value = _searchTextEditingController.text;
  }

  void _onTapSearch() {}

  void _onRemoveKeywordsAll(String keyword) {
    _filters[keyword] = [];
  }

  void _onTapFilter(String value) {
    _filter.value = value;
    _modalUp.value = true;
    _openFilter();
  }

  void _openFilter() {
    _modalUp.value = true;
    showModalBottomSheet(
        transitionAnimationController: _bottomModalController,
        elevation: 30,
        enableDrag: false,
        isDismissible: false,
        isScrollControlled: true,
        context: context,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.hPadding),
        ),
        builder: (BuildContext context) {
          return _filterView();
        });
  }

  void _onTapRefreshFilter(String filter) {
    _modalUp.value = false;
    _filters[filter] = [];
    _filterToReqParams();
    Navigator.pop(context);
    _refreshPatientList();
  }

  void _onTapAdjustFilter(String filter) {
    _modalUp.value = false;
    _filterToReqParams();
    Navigator.pop(context);
    _refreshPatientList();
  }

  void _onTapPatientCard(PatientDataRes patientData) {
    context.pushNamed('patientPage', extra: patientData);
  }

  void _filterToReqParams() {
    _filters.forEach((key, val) {
      if (key == '담당의') {
        _reqFilters.doctorName = val.isNotEmpty ? val[0] : null;
      } else if (key == '간호사') {
        _reqFilters.nurseName = val.isNotEmpty ? val[0] : null;
      } else if (key == '촬영일자') {
        _reqFilters.lastFeedUpdateDate = val.isNotEmpty
            ? Datetime().getServerDatetime(val[0].year.toString(),
                val[0].month.toString(), val[0].day.toString())
            : null;
      } else if (key == '병동') {
        _reqFilters.roomCode =
            val.isNotEmpty ? val.map((el) => el.toString()).toList() : null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: AppColors.gray01,
        width: context.pWidth,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
              color: Colors.white,
              padding: EdgeInsets.only(
                  left: context.hPadding,
                  right: context.hPadding,
                  top: context.vPadding,
                  bottom: context.vPadding),
              child: Column(children: [
                _searchBar(),
                Padding(padding: EdgeInsets.all(context.vPadding * 0.5)),
                _filterList(),
              ])),
          Expanded(
              child: SingleChildScrollView(
                  child: Container(
                      padding: EdgeInsets.only(
                          top: context.vPadding * 0.5,
                          left: context.hPadding,
                          right: context.hPadding,
                          bottom: context.vPadding),
                      child: Container(child: _searchResultList())))),
        ]));
  }

  Widget _searchBar() {
    return ValueListenableBuilder(
        valueListenable: _searchText,
        builder: (BuildContext context, String value, _) {
          return TextField(
              controller: _searchTextEditingController,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                fillColor: AppColors.blue01,
                contentPadding: EdgeInsets.only(
                    left: context.hPadding, bottom: context.vPadding * 0.5),
                hintText: '이름/등록번호',
                hintStyle: const TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.normal),
                filled: true,
                constraints: BoxConstraints(
                  maxWidth: context.pWidth,
                  maxHeight: context.pHeight * 0.05,
                ),
                suffixIcon: Container(
                    margin: EdgeInsets.only(
                        top: context.vPadding * 0.5,
                        bottom: context.vPadding * 0.6),
                    child: InkWell(
                        onTap: () => _onTapSearch(),
                        child: Icon(Icons.search,
                            size: context.contentsIconSize))),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(context.hPadding * 0.2),
                ),
              ),
              keyboardType: TextInputType.text,
              style: TextStyle(
                color: Colors.black,
                fontSize: context.contentsTextSize,
              ));
        });
  }

  Widget _filterList() {
    return ValueListenableBuilder(
        valueListenable: _filter,
        builder: (BuildContext context, String value, _) {
          return SizedBox(
              width: context.pWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FutureBuilder(
                      future: _doctorFilterListFuture,
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.data != null) {
                          return _filterButtonWithTap('담당의', value);
                        } else {
                          return _filterButton('담당의');
                        }
                      }),
                  FutureBuilder(
                      future: _nurseFilterListFuture,
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.data != null) {
                          return _filterButtonWithTap('간호사', value);
                        } else {
                          return _filterButton('간호사');
                        }
                      }),
                  _filterButtonWithTap('촬영일자', value),
                  _filterButtonWithTap('병동', value),
                ],
              ));
        });
  }

  Widget _filterButton(String title) {
    return Container(
        padding: EdgeInsets.all(context.hPadding * 0.4),
        decoration: BoxDecoration(
          color: AppColors.gray02,
          border: Border.all(color: AppColors.blue02),
          borderRadius: BorderRadius.circular(context.hPadding * 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: context.hPadding * 0.7,
                    fontWeight: FontWeight.bold)),
            Padding(padding: EdgeInsets.all(context.hPadding * 0.1)),
            Container(
                margin: EdgeInsets.zero,
                child: Icon(Icons.keyboard_arrow_up,
                    color: Colors.black, size: context.hPadding))
          ],
        ));
  }

  Widget _filterButtonWithTap(String title, String filter) {
    return ValueListenableBuilder(
        valueListenable: _modalUp,
        builder: (BuildContext context, bool value, _) {
          return InkWell(
              onTap: () => _onTapFilter(title),
              child: Container(
                  padding: EdgeInsets.all(context.hPadding * 0.4),
                  decoration: BoxDecoration(
                    color: value && title == filter
                        ? AppColors.mainColor
                        : Colors.white,
                    border: Border.all(
                        color: value && title == filter
                            ? Colors.white
                            : _filters[title]!.isNotEmpty
                                ? AppColors.mainColor
                                : AppColors.blue02),
                    borderRadius: BorderRadius.circular(context.hPadding * 0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(title,
                          style: TextStyle(
                              color: value && title == filter
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: context.hPadding * 0.7,
                              fontWeight: FontWeight.bold)),
                      Padding(padding: EdgeInsets.all(context.hPadding * 0.1)),
                      Container(
                          margin: EdgeInsets.zero,
                          child: Icon(
                              value && title == filter
                                  ? Icons.keyboard_arrow_down
                                  : Icons.keyboard_arrow_up,
                              color: value && title == filter
                                  ? Colors.white
                                  : Colors.black,
                              size: context.hPadding))
                    ],
                  )));
        });
  }

  Widget _searchResultList() {
    return FutureBuilder(
        future: _patientListFuture,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.data != null) {
            final patientList = snapshot.data!;
            return patientList.isNotEmpty
                ? Column(
                    children: List.generate(
                    patientList.length,
                    (index) => Container(
                        margin: EdgeInsets.only(top: context.vPadding * 0.5),
                        child: InkWell(
                            onTap: () => _onTapPatientCard(patientList[index]),
                            child: ProfileCardDetail(
                              patient: patientList[index],
                            ))),
                  ))
                : Padding(
                    padding: EdgeInsets.only(top: context.vPadding * 2),
                    child: Text('해당하는 환자 데이터가 없습니다.',
                        style: TextStyle(
                            fontSize: context.hPadding * 0.8,
                            color: AppColors.gray04)));
          } else {
            return const SizedBox();
          }
        });
  }

  Widget _filterView() {
    return Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.hPadding),
        ),
        width: context.pWidth,
        height: context.pHeight * 0.5,
        child: Column(children: [
          Expanded(
            flex: 6,
            child: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(
                  top: context.hPadding * 1.5,
                  left: context.hPadding * 1.5,
                  right: context.hPadding * 1.5,
                  bottom: context.hPadding * 1.5,
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 1,
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(_filter.value,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: context.hPadding,
                                      fontWeight: FontWeight.bold)))),
                      Padding(
                        padding: EdgeInsets.all(context.vPadding * 0.5),
                      ),
                      Expanded(
                          flex: 8, child: _renderFilterBody(_filter.value)),
                    ])),
          ),
          Container(
              height: context.pHeight * 0.1,
              width: context.pWidth,
              child: Row(
                children: [
                  InkWell(
                      onTap: () => _onTapRefreshFilter(_filter.value),
                      child: Container(
                          alignment: Alignment.center,
                          width: context.pWidth * 0.5,
                          padding: EdgeInsets.all(context.vPadding),
                          color: AppColors.gray02,
                          child: Text('초기화',
                              style: TextStyle(
                                  color: AppColors.gray03,
                                  fontSize: context.hPadding,
                                  fontWeight: FontWeight.bold)))),
                  InkWell(
                      onTap: () => _onTapAdjustFilter(_filter.value),
                      child: Container(
                          alignment: Alignment.center,
                          width: context.pWidth * 0.5,
                          padding: EdgeInsets.all(context.vPadding),
                          color: AppColors.mainColor,
                          child: Text('적용하기',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.hPadding,
                                  fontWeight: FontWeight.bold)))),
                ],
              ))
        ]));
  }

  Widget _renderFilterBody(String filter) {
    switch (filter) {
      case '담당의':
        return KeywordPicker(
          keywordList: _doctorFilterList,
          keyword: _filters[filter]!,
        );
      case '간호사':
        return KeywordPicker(
          keywordList: _nurseFilterList,
          keyword: _filters[filter]!,
        );
      case '촬영일자':
        return DatePicker(
          datetime: _filters[filter]!,
        );
      case '병동':
        return KeywordAdder(
          list: _filters[filter]!,
        );
      default:
        return const SizedBox();
    }
  }
}
