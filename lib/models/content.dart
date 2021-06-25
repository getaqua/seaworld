import 'flow.dart';

class Content {
  final String? text;
  final Content? original;

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

    author = PartialFlow.fromJSON(data["author"]),
    timestamp = DateTime.parse(data["timestamp"]),
    editedTimestamp = data["editedTimestamp"] != null ? DateTime.parse(data["editedTimestamp"]) : null,
    isEdited = data["edited"] ?? false,
    isPinned = data["pinned"] ?? false,
    inFlowId = data["inFlowId"],
    snowflake = data["snowflake"];
}