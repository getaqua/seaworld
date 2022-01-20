import 'package:seaworld/models/content.dart';

class PartialFlow {
  final Map _map;
  final String name;
  final String? description;
  final String? avatarUrl;
  final String? bannerUrl;
  final String id;
  final String snowflake;
  /// The `effective_permissions` of the acting user.
  final FlowPermissions myPermissions;

  PartialFlow.fromJSON(Map data):
    _map = data,
    name = data["name"] ?? data["id"],
    description = data["description"],
    avatarUrl = data["avatar_url"],
    bannerUrl = data["banner_url"],
    id = data["id"],
    snowflake = data["snowflake"],
    myPermissions = FlowPermissions.fromJSON(data["effective_permissions"]);
  Map toJSON() => _map;
}

class Flow extends PartialFlow {
  final List<PartialFlow> members;
  final List<String> alternativeIds;
  final FlowPermissions publicPermissions;
  final FlowPermissions joinedPermissions;

  Flow.fromJSON(Map data):
    members = data["members"].map<PartialFlow>((v) => PartialFlow.fromJSON(v)).toList(),
    alternativeIds = data["alternative_ids"].whereType<String>().toList() ?? [],
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
  final AllowDeny? join;
  final AllowDeny? view;
  final AllowDeny? read;
  final AllowDeny? post;
  final AllowDeny? delete;
  final AllowDeny? pin;
  final AllowDeny? update;
  
  FlowPermissions.fromJSON(Map data):
    join = data["join"] == "allow" ? AllowDeny.ALLOW : data["join"] == "request" ? AllowDeny.REQUEST : AllowDeny.DENY,
    view = data["view"] == "allow" ? AllowDeny.ALLOW : AllowDeny.DENY,
    read = data["read"] == "allow" ? AllowDeny.ALLOW : AllowDeny.DENY,
    post = data["post"] == "allow" ? AllowDeny.ALLOW : AllowDeny.DENY,
    delete = data["delete"] == "allow" ? AllowDeny.ALLOW : AllowDeny.DENY,
    pin = data["pin"] == "allow" ? AllowDeny.ALLOW : AllowDeny.DENY,
    update = data["update"] == "allow" ? AllowDeny.ALLOW : AllowDeny.DENY;
}
/// Possible values for permissions. [ALLOW] and [DENY] are used by most permissions.
enum AllowDeny {
  /// Used by most permissions.
  // ignore: constant_identifier_names
  ALLOW,
  /// Used by most permissions.
  // ignore: constant_identifier_names
  DENY,
  /// Used by [FlowPermissions.join]
  // ignore: constant_identifier_names
  REQUEST,
  /// Used by [FlowPermissions.impersonate]
  // ignore: constant_identifier_names
  FORCE
}