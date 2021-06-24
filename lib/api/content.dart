import 'package:get/get.dart';
import 'package:seaworld/models/content.dart';
//import 'package:seaworld/models/flow.dart';

class ContentAPI extends GetConnect {
  final String token;
  final String url;

  ContentAPI(this.token, this.url) {
    baseUrl = url+"/_gridless/graphql/";
  }

  Future<List<Content>> followedContent() async => (await query(r"""query followedContent {
    getFollowedContent {
      text
      origin {
        text
        author {
          name
          id
        }
      }
      pinned
      author {
        name
        id
      }
      inFlowId
      timestamp
      # edited
      editedTimestamp
      snowflake
    }
  }""", headers: {"Authorization": "Bearer $token"}, url: baseUrl)).body["getFollowedContent"].map<Content>((v) => Content.fromJSON(v)).toList();
}