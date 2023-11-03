import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:medic_app/consts/sizes.dart';
import 'package:medic_app/consts/colors.dart';
import 'package:medic_app/providers/platform_provider.dart';
import 'package:medic_app/providers/session_provider.dart';
import 'package:medic_app/models/models.dart';
import 'package:medic_app/widgets/basic_struct.dart';
import 'package:medic_app/widgets/contained_button.dart';
import 'package:medic_app/widgets/bordered_button.dart';
import 'package:medic_app/widgets/address_card.dart';
import 'package:medic_app/services/external/kakao_service.dart';

class SearchAddressView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchAddressView();
}

class _SearchAddressView extends State<SearchAddressView> {
  late TextEditingController _searchTextEditingController;
  String _searchText = '';
  int _searchPage = 0;

  ValueNotifier<List<AddressData>> _addressList =
      ValueNotifier<List<AddressData>>([]);
  ValueNotifier<bool> _isSearchMoreTapped = ValueNotifier<bool>(false);
  ValueNotifier<bool> _isSearchEnd = ValueNotifier<bool>(false);
  ValueNotifier<bool> _isInitialized = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _initData();
    _searchTextEditingController = TextEditingController(text: _searchText);
    _searchTextEditingController.addListener(_onSearchTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});
  }

  @override
  void dispose() {
    super.dispose();
    _searchTextEditingController.dispose();
  }

  void _initData() {}

  void _onSearchTextChanged() {
    //_searchText = _searchTextEditingController.text;
  }

  void _onTapSearch() async {
    if (!_isInitialized.value) {
      _isInitialized.value = true;
    }
    _searchText = _searchTextEditingController.text;
    _searchPage = 1;
    _addressList.value = [];
    _isSearchEnd.value = false;
    await _getAddressList();
  }

  void _onTapSearchMore() async {
    _isSearchMoreTapped.value = true;
    _searchPage++;
    await _getAddressList();
    _isSearchMoreTapped.value = false;
  }

  Future<void> _getAddressList() async {
    final platformProvider = Provider.of<Platform>(context, listen: false);
    platformProvider.isLoading = true;
    KakaoService().getAddressList(_searchText, _searchPage).then((value) {
      if (value.containsKey('err')) {
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
      } else {
        _addressList.value
            .insertAll(_addressList.value.length, value['data'].documents);
        _isSearchEnd.value = value['data'].isEnd as bool;
        setState(() {});
      }
    }).whenComplete(() => platformProvider.isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return BasicStruct(
        appBarTitle: '주소 검색',
        childWidget: Container(
            color: Colors.white,
            margin: EdgeInsets.only(
              top: context.vPadding,
              bottom: context.vPadding,
            ),
            padding: EdgeInsets.only(
                left: context.hPadding, right: context.hPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _searchBar(),
                Padding(padding: EdgeInsets.all(context.vPadding * 0.5)),
                _renderAddressList(),
                Padding(padding: EdgeInsets.all(context.vPadding * 0.5)),
                _searchMoreButton(),
              ],
            )));
  }

  Widget _searchBar() {
    return Row(children: [
      Expanded(
          flex: 4,
          child: TextField(
              controller: _searchTextEditingController,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: TextInputAction.go,
              onSubmitted: (val) => _onTapSearch(),
              decoration: InputDecoration(
                fillColor: AppColors.blue01,
                contentPadding: EdgeInsets.only(
                    left: context.hPadding, bottom: context.vPadding * 0.5),
                hintText: '지번, 도로명, 건물명으로 검색',
                hintStyle: const TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.normal),
                filled: true,
                constraints: BoxConstraints(
                  maxWidth: context.pWidth,
                  maxHeight: context.pHeight * 0.05,
                ),
                prefixIcon: Icon(Icons.search,
                    size: context.contentsIconSize, color: Colors.black54),
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
        text: '검색',
        textSize: context.contentsTextSize,
        textColor: Colors.white,
        onPressed: () => _onTapSearch(),
      ))
    ]);
  }

  Widget _renderAddressList() {
    return ValueListenableBuilder(
        valueListenable: _isInitialized,
        builder: (BuildContext context, bool isInit, _) {
          return ValueListenableBuilder(
              valueListenable: _addressList,
              builder: (BuildContext context, List<AddressData> list, _) {
                return isInit
                    ? list.isNotEmpty
                        ? Column(
                            children: List.generate(
                                list.length,
                                (index) => AddressCard(
                                    data: list[index],
                                    onTapSelect: (data) => context.pop(data))))
                        : Text('검색 결과 없음')
                    : const SizedBox();
              });
        });
  }

  Widget _searchMoreButton() {
    return ValueListenableBuilder(
        valueListenable: _isSearchEnd,
        builder: (BuildContext context, bool isEnd, _) {
          return ValueListenableBuilder(
              valueListenable: _addressList,
              builder: (BuildContext context, List<AddressData> list, _) {
                return list.isNotEmpty
                    ? isEnd
                        ? Text('검색 결과 끝')
                        : ValueListenableBuilder(
                            valueListenable: _isSearchMoreTapped,
                            builder: (BuildContext context, bool value, _) {
                              return value
                                  ? CircularProgressIndicator()
                                  : ContainedButton(
                                      onPressed: () => _onTapSearchMore(),
                                      boxWidth: context.pWidth,
                                      color: AppColors.gray03,
                                      text: '검색결과 더 보기',
                                      textColor: AppColors.gray01,
                                    );
                            })
                    : const SizedBox();
              });
        });
  }
}
