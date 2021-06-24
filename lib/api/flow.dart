import 'package:get/get.dart';
import 'package:seaworld/models/flow.dart';

class FlowAPI extends GetConnect {
  final String token;
  final String url;

  FlowAPI(this.token, this.url) {
    baseUrl = url+"/_gridless/graphql/";
  }

  Future<List<Flow>> followedFlows() async => (await query(r"""query followedFlows {
    followedFlows {
      name
      id
    }
  }""", headers: {"Authorization": "Bearer $token"}, url: baseUrl)).body.map((v) => Flow.fromJSON(v["followedFlows"]));

  Future<Flow> getFlow(String id) async => Flow.fromJSON((await query(r"""query followedFlows($id: String) {
    getFlow(id: $id) {
      name
      id
    }
  }""", variables: {id: id}, headers: {"Authorization": "Bearer $token"}, url: baseUrl)).body["getFlow"]);

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