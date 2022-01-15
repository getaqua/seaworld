import 'package:get/get.dart';

import 'apiclass.dart';

class SystemAPI extends APIConnect {
  final String token;
  final String url;

  SystemAPI(this.token, this.url) {
    baseUrl = url+"/_gridless/graphql/";
  }

  Future<GraphQLResponse> getSystemInfo() async => query(r"""query getSystemInfo {
    getSystemInfo {
      name
      version
    }
  }""", headers: {"Authorization": "Bearer $token"}, url: baseUrl);

  Future<GraphQLResponse> getMe() async => query(r"""query getMe {
    getMe {
      tokenPermissions
      user {
        id
      }
    }
  }""", headers: {"Authorization": "Bearer $token"}, url: baseUrl);
}