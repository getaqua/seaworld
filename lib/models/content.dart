import 'flow.dart';

class Content {
  final String? text;
  final Content? original;
  final List<ContentAttachment> attachments;

  PartialFlow author;
  final DateTime timestamp;
  final DateTime? editedTimestamp;
  final bool isEdited;
  final bool isPinned;
  final String inFlowId;
  final String snowflake;

  Content.fromJSON(Map data):
    text = data["text"],
    original = data["origin"] != null ? Content.fromJSON(data["origin"]) : null,
    attachments = data["attachments"]?.map<ContentAttachment>((att) => ContentAttachment.fromJSON(att)).toList() ?? [],

    author = PartialFlow.fromJSON(data["author"]),
    timestamp = DateTime.parse(data["timestamp"]),
    editedTimestamp = data["editedTimestamp"] != null ? DateTime.parse(data["editedTimestamp"]) : null,
    isEdited = data["edited"] ?? false,
    isPinned = data["pinned"] ?? false,
    inFlowId = data["inFlowId"],
    snowflake = data["snowflake"];
}
class ContentAttachment {
  final String url;
  final String? downloadUrl;
  final String? mimeType;
  final String? downloadMimeType;
  final String filename;
  final bool yours;
  final String snowflake;

  ContentAttachment.fromJSON(Map data):
    url = data["url"],
    downloadUrl = data["downloadUrl"],
    mimeType = data["mimeType"],
    downloadMimeType = data["downloadMimeType"],
    filename = data["filename"],
    yours = data["yours"] ?? false,
    snowflake = data["snowflake"];
}