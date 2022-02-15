import 'package:seaworld/models/member.dart';

import 'flow.dart';

class Content {
  final Map _map;
  final String? text;
  final Content? original;
  final List<ContentAttachment> attachments;

  PartialFlowMember author;
  final DateTime timestamp;
  final DateTime? editedTimestamp;
  final bool isEdited;
  final bool isPinned;
  final String inFlowId;
  final bool yours;
  final String snowflake;

  Content.fromJSON(Map data):
    _map = data,
    text = data["text"],
    original = data["origin"] != null ? Content.fromJSON(data["origin"]) : null,
    attachments = data["attachments"]?.map<ContentAttachment>((att) => ContentAttachment.fromJSON(att)).toList() ?? [],

    author = PartialFlowMember.fromJSON(data["author"]),
    timestamp = DateTime.parse(data["timestamp"]),
    editedTimestamp = data["editedTimestamp"] != null ? DateTime.parse(data["editedTimestamp"]) : null,
    isEdited = data["editedTimestamp"] != null,
    isPinned = data["pinned"] ?? false,
    inFlowId = data["inFlowId"],
    yours = data["yours"] ?? false,
    snowflake = data["snowflake"];
  Map toJSON() => _map;
}
class ContentAttachment {
  final Map _map;
  final String url;
  final String? downloadUrl;
  final String? mimeType;
  final String? downloadMimeType;
  final String filename;
  final bool yours;
  final String snowflake;

  ContentAttachment.fromJSON(Map data):
    _map = data,
    url = data["url"],
    downloadUrl = data["downloadUrl"],
    mimeType = data["mimeType"],
    downloadMimeType = data["downloadMimeType"],
    filename = data["filename"],
    yours = data["yours"] ?? false,
    snowflake = data["snowflake"];
  Map toJSON() => _map;
}