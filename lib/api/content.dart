import 'package:seaworld/api/apiclass.dart';
//import 'package:seaworld/models/flow.dart';

class ContentAPI extends APIConnect {
  final String token;
  final String url;

  ContentAPI(this.token, this.url) : super(url+"/_gridless/graphql/");

  static const followedContent = r"""query followedContent {
    getFollowedContent {
      ...content
    }
  }""";

  // Future<GraphQLResponse> postContent({
  //   required String toFlow,
  //   String? text,
  //   List<String>? attachments
  // }) async => mutation(, headers: {"Authorization": "Bearer $token"}, url: "/", variables: {
  //   "id": toFlow,
  //   "data": {
  //     if (text != null) "text": text,
  //     if (attachments != null) "attachments": attachments
  //   }
  // });
  static const postContent = r"""mutation postToFlow($id: String!, $data: NewContent!) {
    postContent(to: $id, data: $data) {
      snowflake
    }
  }""";

  static const updateContent = r"""mutation editContent($id: String!, $data: EditedContent!) {
    updateContent(id: $id, data: $data) {
      snowflake
    }
  }""";

  static const deleteContent = r"""mutation deleteContent($id: String!) {
    deleteContent(snowflake: $id)
  }""";
}