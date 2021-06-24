import 'package:get/get.dart';
import 'package:seaworld/helpers/config.dart';
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

  Future<GraphQLResponse> postContent({required String toFlow, String? text}) async => mutation(r"""mutation postToFlow($id: String!, $data: NewContent!) {
    postContent(to: $id, data: $data) {
      snowflake
    }
  }""", headers: {"Authorization": "Bearer $token"}, url: baseUrl, variables: {
    "id": toFlow,
    "data": {
      if (text != null) "text": text
    }
  });
}