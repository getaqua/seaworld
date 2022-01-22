
import 'apiclass.dart';

class FlowAPI extends APIConnect {
  final String token;
  final String url;

  FlowAPI(this.token, this.url) : super(url+"/_gridless/graphql/");

  static const followedFlows = r"""query followedFlows {
    getFollowedFlows {
      ...partialFlow
    }
  }""";

  static const joinedFlows = r"""query joinedFlows {
    getJoinedFlows {
      ...partialFlow
    }
  }""";

  static const getFlow = r"""query getFlow($id: String!) {
    getFlow(id: $id) {
      ...fullFlow
    }
  }""";

  static const getFlowWithContent = r"""query getFlowWithContent($id: String!) {
    getFlow(id: $id) {
      ...fullFlow
      content {
        ...content
      }
    }
  }""";

  static const updateFlow = r"""mutation updateFlow($id: String!, $data: PatchedFlow!) {
    updateFlow(id: $id, data: $data) {
      snowflake
    }
  }""";

  static const followFlow = r"""mutation followFlow($id: String!) {
    followFlow(id: $id)
  }""";
  static const unfollowFlow = r"""mutation unfollowFlow($id: String!) {
    unfollowFlow(id: $id)
  }""";

  static const joinFlow = r"""mutation joinFlow($id: String!) {
    joinFlow(id: $id) {
      snowflake
    }
  }""";
  static const leaveFlow = r"""mutation leaveFlow($id: String!) {
    leaveFlow(id: $id)
  }""";

  /* Mutations to implement:
  createFlow(flow: NewFlow, parentId: String) : Flow
  updateFlow(id: String!, data: PatchedFlow!): Flow
  deleteFlow(id: String!): Boolean!
  joinFlow(id: String!, inviteCode: String): Flow
  */
}