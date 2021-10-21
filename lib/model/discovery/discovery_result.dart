import 'package:ble_project/model/discovery/discovery_entity.dart';
import 'package:ble_project/model/vod_info.dart';

class DiscoveryResult {
  static List<DiscoveryGroupInfo> makeDiscoveryGroups(DiscoveryEntity discoveryEntity) {
    List<DiscoveryGroupInfo> list = [];
    discoveryEntity.data.map((e1) => e1.items.map((e2) => list.add(DiscoveryGroupInfo(e1.id, e1.id.toString() + "-" + e1.name, e2))).toList()).toList();
    return list;
  }
}

class DiscoveryGroupInfo {
  int id;
  String name;
  VodInfo vodInfo;

  DiscoveryGroupInfo(this.id, this.name, this.vodInfo);

  @override
  String toString() {
    return 'DiscoveryGroupInfo{id: $id, name: $name, vodInfo: $vodInfo}';
  }
}