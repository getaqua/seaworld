import 'package:get/get.dart';
import 'package:seaworld/helpers/apierror.dart';
import 'package:seaworld/models/flow.dart';

import 'apiclass.dart';

class FlowAPI extends APIConnect {
  final String token;
  final String url;

  FlowAPI(this.token, this.url) {
    baseUrl = url+"/_gridless/graphql/";
  }

  Future<List<T>> followedFlows<T extends PartialFlow>() async => Future<List<T>>(() async => (await query(r"""query followedFlows {
    getFollowedFlows {
      ...partialFlow
    }
  }""", headers: {"Authorization": "Bearer $token"}, url: baseUrl)).body["getFollowedFlows"].map<T>((v) => T == Flow ? Flow.fromJSON(v) : PartialFlow.fromJSON(v)).toList())
  .catchError((error) => throw APIErrorHandler.handleError(error) ?? error);
  Future<List<T>> joinedFlows<T extends PartialFlow>() async => Future<List<T>>(() async => (await query(r"""query followedFlows {
    getJoinedFlows {
      ...partialFlow
    }
  }""", headers: {"Authorization": "Bearer $token"}, url: baseUrl)).body["getJoinedFlows"].map<T>((v) => T == Flow ? Flow.fromJSON(v) : PartialFlow.fromJSON(v)).toList())
  .catchError((error) => throw APIErrorHandler.handleError(error) ?? error);

  Future<Flow> getFlow(String id) async => Future(() async => Flow.fromJSON((await query(r"""query getFlow($id: String!) {
    getFlow(id: $id) {
      ...fullFlow
    }
  }""", variables: {id: id}, headers: {"Authorization": "Bearer $token"}, url: baseUrl)).body["getFlow"]))
  .catchError((error) => throw APIErrorHandler.handleError(error) ?? error);

  Future<FlowWithContent> getFlowAndContent(String id) async => Future(() async => FlowWithContent.fromJSON((await query(r"""query getFlowWithContent($id: String!) {
    getFlow(id: $id) {
      ...fullFlow
      content {
        ...content
      }
    }
  }""", variables: {"id": id}, headers: {"Authorization": "Bearer $token"}, url: baseUrl)).body["getFlow"]))
  .catchError((error) => throw APIErrorHandler.handleError(error) ?? error);

  Future<GraphQLResponse> updateFlow({required String id, String? name, String? description, String? avatarUrl, String? bannerUrl}) => mutation(r"""mutation updateFlow($id: String!, $data: PatchedFlow!) {
    updateFlow(id: $id, data: $data) {
      snowflake
    }
  }""", variables: {
    "id": id,
    "data": {
      if (name != null) "name": name,
      if (description != null) "description": description,
      if (avatarUrl != null) "avatar_url": avatarUrl,
      if (bannerUrl != null) "banner_url": bannerUrl
    }
  }, headers: {"Authorization": "Bearer $token"}, url: baseUrl);

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