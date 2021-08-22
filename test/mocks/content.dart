import 'package:mockito/mockito.dart';
import 'package:seaworld/api/content.dart';
import 'package:seaworld/models/content.dart';

class FakeContentAPI extends Fake implements ContentAPI {
  @override
  Future<List<Content>> followedContent() async => [
    Content.fromJSON({
      "author": {
        "name": "Mock User 1",
        "id": "//mock_user1"
      },
      "text": "This is a test of the API implementation, without having to hook into the API!",
      "snowflake": "A00027BF9388AA000000",
      "inFlowId": "//mock_user1",
      "timestamp": "2021-08-21T19:29:26.312Z"
    })
  ];
}