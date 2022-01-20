
import 'apiclass.dart';

class SystemAPI extends APIConnect {
  final String token;
  final String url;

  SystemAPI(this.token, this.url) : super(url+"/_gridless/graphql/");

  static const getSystemInfo = r"""query getSystemInfo {
    getSystemInfo {
      name
      version
    }
  }""";

  static const getMe = r"""query getMe {
    getMe {
      tokenPermissions
      flow {
        ...fullFlow
      }
    }
  }""";
}