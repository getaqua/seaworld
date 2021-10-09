import 'package:seaworld/models/content.dart';

class PartialFlow {
  final String name;
  final String? description;
  final String id;

  PartialFlow.fromJSON(Map data):
    name = data["name"] ?? data["id"],
    description = data["description"],
    id = data["id"];
}
class Flow extends PartialFlow {
  final List<PartialFlow> members;
  final List<String> alternativeIds;
  final FlowPermissions publicPermissions;
  final FlowPermissions joinedPermissions;

  Flow.fromJSON(Map data):
    members = data["members"].map((v) => PartialFlow.fromJSON(v)),
    alternativeIds = data["alternative_ids"],
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