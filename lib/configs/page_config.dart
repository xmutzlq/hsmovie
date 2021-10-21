import 'package:ble_project/ui/detail/movie_detail_controller/binding.dart';
import 'package:ble_project/ui/detail/movie_detail_controller/view.dart';
import 'package:ble_project/ui/discover/discovery/binding.dart';
import 'package:ble_project/ui/discover/discovery/view.dart';
import 'package:ble_project/ui/home/home_page_mixin_controller/binding.dart';
import 'package:ble_project/ui/more/more/binding.dart';
import 'package:ble_project/ui/more/more/view.dart';
import 'package:ble_project/ui/more/simple_list/binding.dart';
import 'package:ble_project/ui/more/simple_list/view.dart';
import 'package:ble_project/ui/player/player_controller/binding.dart';
import 'package:ble_project/ui/player/player_controller/view.dart';
import 'package:ble_project/ui/ranking/ranking/binding.dart';
import 'package:ble_project/ui/ranking/ranking/view.dart';
import 'package:ble_project/ui/search/search_page_controller/search_logic/binding.dart';
import 'package:ble_project/ui/search/search_page_controller/search_logic/view.dart';
import 'package:get/get.dart';

import '../ui/home/home_page_mixin_controller/view.dart';
part './route_config.dart';

abstract class PageConfig {
  ///别名映射页面
  static final List<GetPage> getPages = [
    GetPage(
      name: RouterConfig.home,
      page: () => HomePageMixin(),
      binding: HomePageBinding()
    ),
    GetPage(
        name: RouterConfig.more,
        page: () => MorePage(),
        binding: MoreBinding()
    ),
    GetPage(
        name: RouterConfig.simple_list,
        page: () => SimpleListPage(),
        binding: SimpleListBinding()
    ),
    GetPage(
      name: RouterConfig.discovery,
      page: () => DiscoveryPage(),
      binding: DiscoveryPageBinding()
    ),
    GetPage(
        name: RouterConfig.ranking,
        page: () => RankingPage(),
        binding: RankingBinding()
    ),
    GetPage(
        name: RouterConfig.search,
        page: () => SearchLogicPage(),
        binding: SearchLogicBinding()
    ),
    GetPage(
        name: RouterConfig.detail,
        page: () => MovieDetailControllerPage(),
        binding: MovieDetailControllerBinding()
    ),
    GetPage(
        name: RouterConfig.player,
        page: () => PlayerControllerPage(),
        binding: PlayerControllerBinding()
    )
  ];
}