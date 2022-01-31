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
  final bool isJoined;
  final bool isFollowing;

  PartialFlow.fromJSON(Map data):
    _map = data,
    name = data["name"] ?? data["id"],
    description = data["description"],
    avatarUrl = data["avatar_url"],
    bannerUrl = data["banner_url"],
    id = data["id"],
    snowflake = data["snowflake"],
    isJoined = data["is_joined"],
    isFollowing = data["is_following"],
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
  final AllowDeny? anonymous;
  
  FlowPermissions.fromJSON(Map data):
    join = data["join"] == null ? null : AllowDeny.values.byName(data["join"]),
    view = data["view"] == null ? null : AllowDeny.values.byName(data["view"]),
    read = data["read"] == null ? null : AllowDeny.values.byName(data["read"]),
    post = data["post"] == null ? null : AllowDeny.values.byName(data["post"]),
    delete = data["delete"] == null ? null : AllowDeny.values.byName(data["delete"]),
    pin = data["pin"] == null ? null : AllowDeny.values.byName(data["pin"]),
    update = data["update"] == null ? null : AllowDeny.values.byName(data["update"]),
    anonymous = data["anonymous"] == null ? null : AllowDeny.values.byName(data["anonymous"]);
}
/// Possible values for permissions. [ALLOW] and [DENY] are used by most permissions.
enum AllowDeny {
  /// Used by most permissions.
  allow,
  /// Used by most permissions.
  deny,
  /// Used by [FlowPermissions.join]
  request,
  /// Used by [FlowPermissions.anonymous]
  force
}