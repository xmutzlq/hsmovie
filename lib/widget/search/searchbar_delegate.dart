import 'dart:async';
import 'dart:math';

import 'package:ble_project/base/theme/app_theme.dart';
import 'package:ble_project/configs/page_config.dart';
import 'package:ble_project/model/search/search_entity.dart';
import 'package:ble_project/model/search/search_entity_suggestion.dart';
import 'package:ble_project/model/vod_info.dart';
import 'package:ble_project/repository/movie_repository.dart';
import 'package:ble_project/ui/search/search_page_controller/search_logic/logic.dart';
import 'package:ble_project/util/sp.dart';
import 'package:ble_project/util/time_util.dart';
import 'package:ble_project/widget/common_state_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' show Get, Inst, GetNavigation;

/// 搜索逻辑委托类
class SearchBarDelegate extends SearchDelegate<SearchEntity> {
  List<String>? searchHistory;
  var logic = Get.find<SearchLogicLogic>();

  final ValueNotifier<String> _searchTrigger = ValueNotifier('');
  Timer? _debounceTimer;
  String _lastQuery = '';
  bool needRequest = false;

  @override
  String? get searchFieldLabel => 'common.search_film'.tr();

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = "";
            _debounceTimer?.cancel();
            showSuggestions(context);
          },
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        _debounceTimer?.cancel();
        logic.clearSearchSuggestionsLocalData();
        close(context, SearchEntity(List.empty(), 0));
      },
    );
  }

  Future<List<String>> _getHistory() async {
    searchHistory = SpUtil().getStringList('searchHistory');
    return searchHistory!;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchTrigger.dispose();
    super.dispose();
  }

  /// 搜索结果
  @override
  Widget buildResults(BuildContext context) {
    debugPrint("buildResults");
    if (query.isNotEmpty) {
      int index = searchHistory?.indexOf(query) ?? 0;
      if (index < 0) {
        debugPrint("buildResults -> save search result");
        searchHistory!.insert(0, query);
        SpUtil().setStringList('searchHistory', searchHistory!);
      }
    }
    return FutureBuilder<SearchEntity>(
      future: logic.getSearchRemoteData(query, logic.state.page.toString()),
      // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<SearchEntity> snapshot) {
        debugPrint("buildResults -> search result : ${snapshot.connectionState}");
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return Container(child: Center(child: Text('common.search_result_none'.tr())));
          case ConnectionState.active:
          case ConnectionState.waiting:
            return _buildLoading(30);
          case ConnectionState.done:
            return snapshot.hasError
                ? screenErrorState('${snapshot.error}')
                : _ResultList(query: query, results: snapshot.data?.data);
        }
      },
    );
  }

  /// 搜索实时输入
  @override
  Widget buildSuggestions(BuildContext context) {
    // 监听查询变化
    if (query != _lastQuery && query.isNotEmpty) {
      _lastQuery = query;
      needRequest = true;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(Duration(milliseconds: 500), () {
        debugPrint("buildSuggestions searchTrigger");
        _searchTrigger.value = query; // 触发 ValueNotifier 更新
      });
    }

    return ValueListenableBuilder<String>(
      valueListenable: _searchTrigger,
      builder: (context, effectiveQuery, child) {
        if (query.isEmpty) {
          return _buildHistoryList();
        }

        if (_debounceTimer?.isActive == true && needRequest) {
          return _buildLoading(30);
        }
        debugPrint("buildSuggestions_query = $query, lastQuery = $_lastQuery");
        debugPrint("buildSuggestions_needRequest = $needRequest");
        return query == _lastQuery && !needRequest
            ? _SuggestionList(
                suggestions: logic.getSearchSuggestionsLocalData().data,
                onSelected: (String suggestion) {
                  query = suggestion;
                  showResults(context);
                },
                emptyChild: _buildHistoryList(),
              )
            : FutureBuilder<SearchEntitySuggestion>(
                future: logic.getSearchSuggestionsRemoteData(query),
                // a previously-obtained Future<String> or null
                builder:
                    (
                      BuildContext context,
                      AsyncSnapshot<SearchEntitySuggestion> snapshot,
                    ) {
                      needRequest = false;
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          return _buildHistoryList();
                        case ConnectionState.active:
                        case ConnectionState.waiting:
                          return _buildLoading(30);
                        case ConnectionState.done:
                          if (snapshot.hasError) {
                            return screenErrorState('${snapshot.error}');
                          } else {
                            return _SuggestionList(
                              suggestions: snapshot.data?.data,
                              onSelected: (String suggestion) {
                                query = suggestion;
                                showResults(context);
                              },
                              emptyChild: _buildHistoryList(),
                            );
                          }
                      }
                    },
              );
      },
    );
  }

  Widget _buildLoading(double topMargin) {
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      alignment: Alignment.topCenter,
      child: const CircularProgressIndicator(
        valueColor: const AlwaysStoppedAnimation(Colors.black),
      ),
    );
  }

  Widget _buildHistoryList() {
    var width = MediaQuery.of(Get.context!).size.width;
    return FutureBuilder<List<String>>(
      future: _getHistory(), // a previously-obtained Future<String> or null
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return _buildHistoryList();
          case ConnectionState.active:
          case ConnectionState.waiting:
            return _buildLoading(15);
          case ConnectionState.done:
            if (snapshot.hasError) return screenErrorState('${snapshot.error}');
            return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 15, 0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'common.search_history'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        searchHistory != null && searchHistory!.length > 0
                            ? SizedBox(
                                height: 40,
                                child: IconButton(
                                  padding: const EdgeInsets.all(0),
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () {
                                    if (searchHistory != null &&
                                        searchHistory!.length > 0) {
                                      searchHistory = [];
                                      SpUtil().remove('searchHistory');
                                      query = '';
                                      _searchTrigger.value = query;
                                    }
                                  },
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                  searchHistory != null && searchHistory!.length > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          width: width,
                          child: Wrap(
                            spacing: 20,
                            children: searchHistory!.take(10).map((s) {
                              return ActionChip(
                                avatar: Icon(
                                  Icons.history,
                                  color: Colors.grey[500],
                                ),
                                // backgroundColor: Colors.grey[200],
                                label: Text(s),
                                //labelStyle: TextStyle(color: Colors.black87),
                                onPressed: () {
                                  query = s;
                                  showResults(context);
                                },
                              );
                            }).toList(),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.only(left: 15, top: 10),
                          child: Text('common.search_history'.tr()),
                        ),
                ],
              ),
            );
        }
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final _lightTheme = theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey),
      ),
      primaryColor: Colors.white,
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryTextTheme: theme.textTheme,
    );
    final _darkTheme = theme.copyWith(
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: const TextStyle(color: Colors.grey),
      ),
      primaryColor: const Color(0xFF303030),
      primaryIconTheme: theme.primaryIconTheme.copyWith(color: Colors.grey),
      primaryTextTheme: theme.textTheme,
    );
    final MediaQueryData _mediaQuery = MediaQuery.of(context);
    final ThemeData _newTheme =
        _mediaQuery.platformBrightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    return _newTheme.copyWith(
      textSelectionTheme: theme.textSelectionTheme.copyWith(
        cursorColor: kPrimaryColor,
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        border: InputBorder.none,
        hintStyle: TextStyle(fontSize: 15),
      ),
    );
  }
}

class _SuggestionList extends StatelessWidget {
  final List<VodInfo>? suggestions;
  final ValueChanged<String> onSelected;
  final Widget? emptyChild;

  const _SuggestionList({
    required this.suggestions,
    required this.onSelected,
    required this.emptyChild,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("suggestions.length = ${suggestions?.length ?? 0}");
    if (suggestions?.isEmpty ?? true) {
      return Column(
        children: [
          emptyChild ?? const SizedBox(),
          Expanded(child: screenEmptyState()),
        ],
      );
    } else {
      return ListView.builder(
        itemCount: suggestions!.length,
        itemBuilder: (BuildContext context, int i) {
          final VodInfo suggestion = suggestions![i];
          return _buildSuggestionCell(suggestion, onSelected);
        },
      );
    }
  }

  Widget _buildSuggestionCell(VodInfo s, ValueChanged<String> tapped) {
    String name = s.vodName;
    return Container(
      child: ListTile(title: Text(name), onTap: () => tapped(name)),
    );
  }
}

Random _random = Random(DateTime.now().millisecondsSinceEpoch);

Widget _buildResultCell(VodInfo vodInfo, BuildContext ctx) {
  var width = MediaQuery.of(Get.context!).size.width;
  final _rightPanelWidth = width - 170;
  return GestureDetector(
    onTap: () async {
      Get.offNamed(RouterConfigs.detail, arguments: {'movieId': vodInfo.vodID});
    },
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      constraints: const BoxConstraints(minHeight: 150),
      child: Row(
        children: [
          Container(
            height: 150,
            width: 110,
            decoration: BoxDecoration(
              color: Color.fromRGBO(
                _random.nextInt(255),
                _random.nextInt(255),
                _random.nextInt(255),
                _random.nextDouble(),
              ),
              borderRadius: const BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: Radius.zero,
                bottomLeft: const Radius.circular(10.0),
                bottomRight: const Radius.circular(35.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: appThemeData.brightness == Brightness.light
                      ? const Color(0xFF8E8E8E)
                      : const Color(0x00000000),
                  offset: const Offset(0, 15),
                  blurRadius: 10,
                  spreadRadius: -10,
                ),
              ],
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(vodInfo.vodPic),
              ),
            ),
          ),
          const SizedBox(width: 20),
          SizedBox(
            width: _rightPanelWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vodInfo.vodName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                    ),
                    children: <InlineSpan>[
                      TextSpan(text: 'detail.detail_year_area'.tr()),
                      TextSpan(
                        text: vodInfo.vodYear,
                        style: TextStyle(
                          color: const Color(0xFF109E9E),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      TextSpan(text: " ${vodInfo.vodArea}"),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'detail.detail_actor'.tr(namedArgs: {'vodActor': '${vodInfo.vodActor}'}),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'detail.detail_publish_time'.tr(
                      namedArgs: {'vodTime': '${TimeUtil.timeStampToTimeStr(vodInfo.vodTime)}'}),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: secondaryColor,
                    fontWeight: FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ResultList extends StatefulWidget {
  final List<VodInfo>? results;
  final String query;

  const _ResultList({required this.results, required this.query});

  @override
  _ResultListState createState() => _ResultListState();
}

class _ResultListState extends State<_ResultList> {
  late ScrollController scrollController;
  late List<VodInfo>? results;
  late String query;
  late int pageIndex;
  late int totalPage;
  late bool isLoading;

  Future loadData() async {
    bool isBottom =
        scrollController.position.pixels ==
        scrollController.position.maxScrollExtent;
    if (isBottom && totalPage > pageIndex) {
      setState(() {
        isLoading = true;
      });
      pageIndex++;
      final searchData = await MovieRepository().fetchSearchResultByPage(
        query,
        pageIndex.toString(),
      );
      setState(() {
        if (searchData.ok) {
          if (searchData.data == null || searchData.data['data'] == null) {
            ///错误的话，页减1
            pageIndex--;
          } else {
            SearchEntity searchEntity = SearchEntity.fromJson(searchData.data);

            ///算出总页数
            totalPage = ((searchEntity.qty + 36 - 1) / 36).truncate();
            debugPrint("totalPage = $totalPage");
            results!.addAll(searchEntity.data);
          }
        } else {
          ///错误的话，页减1
          pageIndex--;
        }
        isLoading = false;
      });
    }
  }

  Widget _buildFooter() {
    return Offstage(
      offstage: !isLoading,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          valueColor: const AlwaysStoppedAnimation(Colors.black),
        ),
      ),
    );
  }

  @override
  void initState() {
    results = widget.results ?? [];
    query = widget.query;
    pageIndex = 1;
    totalPage = 2;
    isLoading = false;
    scrollController = ScrollController()..addListener(loadData);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("results.length = ${results?.length ?? 0}");
    if (results?.isEmpty ?? true) {
      return screenEmptyStateFull();
    } else {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: ListView(
          cacheExtent: 500,
          shrinkWrap: true,
          controller: scrollController,
          children:
          results!.map((result) => _buildResultCell(result, context)).toList()
            ..add(_buildFooter()),
        ),
      );
    }
  }
}
