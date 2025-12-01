import 'package:ble_project/model/search/search_entity.dart';
import 'package:ble_project/model/search/search_entity_suggestion.dart';
import 'package:ble_project/repository/movie_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'state.dart';

class SearchLogicLogic extends GetxController{
  final SearchLogicState state = SearchLogicState();
  SearchEntitySuggestion? _suggestion;

  Future<SearchEntity> getSearchRemoteData(String keyword, String page) async {
    var searchData = await MovieRepository().fetchSearchResultByPage(keyword, page);
    if(searchData.ok) {
      return SearchEntity.fromJson(searchData.data);
    } else {
      throw Exception(searchData.error?.message);
    }
  }

  SearchEntitySuggestion getSearchSuggestionsLocalData() {
    return _suggestion ?? SearchEntitySuggestion(List.empty());
  }

  void clearSearchSuggestionsLocalData() {
    _suggestion = SearchEntitySuggestion(List.empty());
  }

  Future<SearchEntitySuggestion> getSearchSuggestionsRemoteData(String keyword) async {
    var searchData = await MovieRepository().fetchSearchSuggestions(keyword);
    if(searchData.ok) {
      debugPrint("searchData.data = ${searchData.data}");
      if(searchData.data == null || searchData.data['data'] == null) {
        _suggestion = SearchEntitySuggestion(List.empty());
      } else {
        _suggestion = SearchEntitySuggestion.fromJson(searchData.data);
      }
      return _suggestion!;
    } else {
      throw Exception(searchData.error?.message);
    }
  }
}
