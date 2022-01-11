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
  }""", headers: {"Authorization": "Bearer $token"}, url: "/")).body?["getFollowedContent"]?.map<Content>((v) => Content.fromJSON(v)).toList();

  Future<GraphQLResponse> postContent({required String toFlow, String? text}) async => mutation(r"""mutation postToFlow($id: String!, $data: NewContent!) {
    postContent(to: $id, data: $data) {
      snowflake
    }
  }""", headers: {"Authorization": "Bearer $token"}, url: "/", variables: {
    "id": toFlow,
    "data": {
      if (text != null) "text": text
    }
  });
  Future<GraphQLResponse> updateContent({required String id, String? text}) async => mutation(r"""mutation editContent($id: String!, $data: EditedContent!) {
    updateContent(id: $id, data: $data) {
      snowflake
    }
  }""", headers: {"Authorization": "Bearer $token"}, url: "/", variables: {
    "id": id,
    "data": {
      if (text != null) "text": text
    }
  });

  Future<GraphQLResponse> deleteContent({required String snowflake, String? text}) async => mutation(r"""mutation deleteContent($id: String!) {
    deleteContent(snowflake: $id)
  }""", headers: {"Authorization": "Bearer $token"}, url: "/", variables: {
    "id": snowflake
  });
}