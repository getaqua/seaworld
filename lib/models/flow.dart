import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:seaworld/models/content.dart';
import 'package:seaworld/models/member.dart';

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
  /// The `effectivePermissions` of the acting user.
  final FlowPermissions myPermissions;
  final bool isJoined;
  final bool isFollowing;

  PartialFlow.fromJSON(Map data):
    _map = data,
    name = data["name"] ?? data["id"],
    description = data["description"],
    avatarUrl = data["avatarUrl"],
    bannerUrl = data["bannerUrl"],
    id = data["id"],
    snowflake = data["snowflake"],
    isJoined = data["isJoined"],
    isFollowing = data["isFollowing"],
    myPermissions = FlowPermissions.fromJson(data["effectivePermissions"]);
  Map toJSON() => _map;
}

class Flow extends PartialFlow {
  final List<PartialFlowMember> members;
  final FlowPermissions publicPermissions;
  final FlowPermissions joinedPermissions;

  Flow.fromJSON(Map data):
    members = data["members"].map<PartialFlowMember>((v) => PartialFlowMember.fromJSON(v)).toList(),
    //alternativeIds = data["alternative_ids"].whereType<String>().toList() ?? [],
    publicPermissions = FlowPermissions.fromJson(data["publicPermissions"]),
    joinedPermissions = FlowPermissions.fromJson(data["joinedPermissions"]),
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

  // The following fallback permissions are copied from the Gridless source code.
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