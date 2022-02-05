import 'package:seaworld/models/flow.dart';

class PartialFlowMember {
  final Map _map;
  final String name;
  //final String? description;
  final String? avatarUrl;
  //final String? bannerUrl;
  //final String id;
  //final String snowflake;
  final PartialFlow member;

  PartialFlowMember.fromJSON(Map data):
    _map = data,
    name = data["name"] ?? data["member"]["id"],
    //description = data["description"],
    avatarUrl = data["avatarUrl"],
    //bannerUrl = data["bannerUrl"],
    member = PartialFlow.fromJSON(data["member"]);
  Map toJSON() => _map;
}