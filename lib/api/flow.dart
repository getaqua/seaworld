
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

  /* Mutations to implement:
  createFlow(flow: NewFlow, parentId: String) : Flow
  updateFlow(id: String!, data: PatchedFlow!): Flow
  joinFlow(id: String!, inviteCode: String): Flow
  deleteFlow(id: String!): Boolean!
  leaveFlow(id: String!): Boolean!
  followFlow(id: String!): Boolean!
  unfollowFlow(id: String!): Boolean!
  */
}