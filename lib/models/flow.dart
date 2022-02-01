import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:seaworld/models/content.dart';

part 'flow.freezed.dart';
part 'flow.g.dart';

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
    myPermissions = FlowPermissions.fromJson(data["effective_permissions"]);
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
    publicPermissions = FlowPermissions.fromJson(data["public_permissions"]),
    joinedPermissions = FlowPermissions.fromJson(data["joined_permissions"]),
    super.fromJSON(data);
}
class FlowWithContent extends Flow {
  final List<Content> content;

  FlowWithContent.fromJSON(Map data):
    content = data['content'].map<Content>((v) => Content.fromJSON(v)).toList(),
    super.fromJSON(data);
}

@freezed
class FlowPermissions with _$FlowPermissions {
  factory FlowPermissions({
    AllowDeny? join,
    AllowDeny? view,
    AllowDeny? read,
    AllowDeny? post,
    AllowDeny? delete,
    AllowDeny? pin,
    AllowDeny? update,
    AllowDeny? anonymous,
  }) = _FlowPermissions;

  factory FlowPermissions.fromJson(Map<String, dynamic> json) => _$FlowPermissionsFromJson(json);
  
  // FlowPermissions.fromJSON(Map data):
  //   join = data["join"] == null ? null : AllowDeny.values.byName(data["join"]),
  //   view = data["view"] == null ? null : AllowDeny.values.byName(data["view"]),
  //   read = data["read"] == null ? null : AllowDeny.values.byName(data["read"]),
  //   post = data["post"] == null ? null : AllowDeny.values.byName(data["post"]),
  //   delete = data["delete"] == null ? null : AllowDeny.values.byName(data["delete"]),
  //   pin = data["pin"] == null ? null : AllowDeny.values.byName(data["pin"]),
  //   update = data["update"] == null ? null : AllowDeny.values.byName(data["update"]),
  //   anonymous = data["anonymous"] == null ? null : AllowDeny.values.byName(data["anonymous"]);
  static final publicFallbacks = FlowPermissions(
    view: AllowDeny.allow,
    read: AllowDeny.allow,
    post: AllowDeny.deny,
    pin: AllowDeny.deny,
    join: AllowDeny.request,
    delete: AllowDeny.deny,
    update: AllowDeny.deny,
    anonymous: AllowDeny.deny
  );
  static final joinedFallbacks = FlowPermissions(
    view: AllowDeny.allow,
    read: AllowDeny.allow,
    post: AllowDeny.allow,
    pin: AllowDeny.allow,
    delete: AllowDeny.deny,
    update: AllowDeny.deny,
    anonymous: AllowDeny.deny
  );
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