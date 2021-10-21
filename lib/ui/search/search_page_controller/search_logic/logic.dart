import 'package:ble_project/model/search/search_entity.dart';
import 'package:ble_project/model/search/search_entity_suggestion.dart';
import 'package:ble_project/repository/movie_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import 'state.dart';

class SearchLogicLogic extends GetxController {
  final SearchLogicState state = SearchLogicState();

  Future<SearchEntity> getSearchRemoteData(String keyword, String page) async {
    var searchData = await MovieRepository().fetchSearchResultByPage(keyword, page);
    if(searchData.ok) {
      return SearchEntity.fromJson(searchData.data);
    } else {
      throw Exception(searchData.error?.message);
    }
  }

  Future<SearchEntitySuggestion> getSearchSuggestionsRemoteData(String keyword) async {
    var searchData = await MovieRepository().fetchSearchSuggestions(keyword);
    if(searchData.ok) {
      debugPrint("searchData.data = ${searchData.data}");
      if(searchData.data == null || searchData.data['data'] == null) {
        return SearchEntitySuggestion(List.empty());
      } else {
        return SearchEntitySuggestion.fromJson(searchData.data);
      }
    } else {
      throw Exception(searchData.error?.message);
    }
  }
}
