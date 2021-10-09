import 'package:get/get.dart';
import 'package:seaworld/helpers/apierror.dart';
import 'package:seaworld/models/flow.dart';

class FlowAPI extends GetConnect {
  final String token;
  final String url;

  FlowAPI(this.token, this.url) {
    baseUrl = url+"/_gridless/graphql/";
  }

  Future<List<Flow>> followedFlows() async => Future<List<Flow>>(() async => (await query(r"""query followedFlows {
    followedFlows {
      name
      id
    }
  }""", headers: {"Authorization": "Bearer $token"}, url: baseUrl)).body["followedFlows"].map((v) => Flow.fromJSON(v)))
  .catchError((error) => throw APIErrorHandler.handleError(error) ?? error);

  Future<Flow> getFlow(String id) async => Future(() async => Flow.fromJSON((await query(r"""query getFlow($id: String) {
    getFlow(id: $id) {
      name
      description
      id
    }
  }""", variables: {id: id}, headers: {"Authorization": "Bearer $token"}, url: baseUrl)).body["getFlow"]))
  .catchError((error) => throw APIErrorHandler.handleError(error) ?? error);

  Future<FlowWithContent> getFlowAndContent(String id) async => Future(() async => FlowWithContent.fromJSON((await query(r"""query getFlowWithContent($id: String) {
    getFlow(id: $id) {
      name
      description
      id
      content {
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
    }
  }""", variables: {id: id}, headers: {"Authorization": "Bearer $token"}, url: baseUrl)).body["getFlow"]))
  .catchError((error) => throw APIErrorHandler.handleError(error) ?? error);

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