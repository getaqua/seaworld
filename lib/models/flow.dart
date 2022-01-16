import 'package:seaworld/models/content.dart';

class PartialFlow {
  final String name;
  final String? description;
  final String? avatarUrl;
  final String id;
  final String snowflake;
  /// The `effective_permissions` of the acting user.
  final FlowPermissions myPermissions;

  PartialFlow.fromJSON(Map data):
    name = data["name"] ?? data["id"],
    description = data["description"],
    avatarUrl = data["avatar_url"],
    id = data["id"],
    snowflake = data["snowflake"],
    myPermissions = FlowPermissions.fromJSON(data["effective_permissions"]);
}
class Flow extends PartialFlow {
  final List<PartialFlow> members;
  final List<String> alternativeIds;
  final String? bannerUrl;
  final FlowPermissions publicPermissions;
  final FlowPermissions joinedPermissions;

  Flow.fromJSON(Map data):
    members = data["members"].map<PartialFlow>((v) => PartialFlow.fromJSON(v)).toList(),
    alternativeIds = data["alternative_ids"].whereType<String>().toList() ?? [],
    bannerUrl = data["banner_url"],
    publicPermissions = FlowPermissions.fromJSON(data["public_permissions"]),
    joinedPermissions = FlowPermissions.fromJSON(data["joined_permissions"]),
    super.fromJSON(data);
}
class FlowWithContent extends Flow {
  final List<Content> content;

  FlowWithContent.fromJSON(Map data):
    content = data['content'].map<Content>((v) => Content.fromJSON(v)).toList(),
    super.fromJSON(data);
}
class FlowPermissions {
  final AllowDenyRequest? join;
  final AllowDeny? view;
  final AllowDeny? read;
  final AllowDeny? post;
  final AllowDeny? delete;
  final AllowDeny? pin;
  
  FlowPermissions.fromJSON(Map data):
    join = data["join"] == "allow" ? AllowDenyRequest.allow : data["join"] == "request" ? AllowDenyRequest.request : AllowDenyRequest.deny,
    view = data["view"] == "allow" ? AllowDeny.allow : AllowDeny.deny,
    read = data["read"] == "allow" ? AllowDeny.allow : AllowDeny.deny,
    post = data["post"] == "allow" ? AllowDeny.allow : AllowDeny.deny,
    delete = data["delete"] == "allow" ? AllowDeny.allow : AllowDeny.deny,
    pin = data["pin"] == "allow" ? AllowDeny.allow : AllowDeny.deny;
}
enum AllowDeny {
  allow,
  deny
}
enum AllowDenyRequest {
  allow,
  deny,
  request
}