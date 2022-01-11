import 'dart:async';

import 'package:get/get.dart';
import 'package:get/get_connect/connect.dart';
import 'package:seaworld/api/content.dart';
import 'package:seaworld/api/system.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/models/content.dart';
import 'package:seaworld/models/flow.dart';
import 'package:seaworld/views/crash.dart';

import 'flow.dart';

class API {
  static API get get => _instance ??= API();
  static API? _instance;
  
  bool isServerInsecure = false;
  String get urlScheme => isServerInsecure ? "http://" : "https://";
  late String token;

  Future<bool> get ready => _ready.future;
  Completer<bool> _ready = Completer<bool>();

  /// Whether the API initialization process has completed.
  bool isReady = false;

  static bool _isLocalhost(String url) => 
    url.startsWith("localhost") 
    && (url.startsWith("localhost:") || url == "localhost");

  API();

  /// The `to` parameter is used for tests ONLY.
  /// There's another way for what you're doing
  /// if this isn't used for tests.
  /// Figure it out.
  /// 
  /// Otherwise, this function resets the API,
  /// like what should happen on logout or user
  /// change.
  void reset({dynamic to}) {
    if (to == null) {
      isReady = false;
      _ready = Completer<bool>();
    } else {
      _instance = to;
    }
  }

  Future<void> init(String token, [bool? isServerInsecure]) async {
    this.isServerInsecure = isServerInsecure ?? _isLocalhost(Config.server);
    system = SystemAPI(token, urlScheme+Config.server);
    flow = FlowAPI(token, urlScheme+Config.server);
    content = ContentAPI(token, urlScheme+Config.server);
    this.token = token;
    try {
      await system.getSystemInfo().then((value) {
        Config.cache.serverName = value.body["getSystemInfo"]["name"];
        Config.cache.serverVersion = value.body["getSystemInfo"]["version"];
      });
      await system.getMe().then((value) {
        Config.cache.userId = value.body["getMe"]["user"]["id"];
        Config.cache.scopes = List.castFrom(value.body["getMe"]["tokenPermissions"]);
      });
      isReady = true;
      _ready.complete(true);
    } catch(e) {
      Get.off(() => CrashedView(
        title: "crash.connectionerror.title".tr,
        helptext: e.toString().contains('[]("errors")')
        ? "crash.connectionerror.generic".tr
        : e.toString()
      ));
    }
  }
  //final _flowApi;
  late SystemAPI system;
  late FlowAPI flow;
  late ContentAPI content;

  /// Get system information.
  /// Get these values from it like a Map:
  /// * `name`
  /// * `version`
  /// 
  /// Alternatively, retrieve the values from Config.cache, as the API
  /// initializer sets them there.
  static Future<GraphQLResponse> getSystemInfo() => get.system.getSystemInfo();

  /// Get the user to whom the token corresponds.
  /// Get these values from it like a Map:
  /// * `username`
  /// * `user`.`id`
  static Future<GraphQLResponse> getMe() => get.system.getMe();

  /// Get the Flows the user is following.
  static Future<List<Flow>> followedFlows() => get.flow.followedFlows();
  
  /// Get the latest Content from the Flows the user is following.
  static Future<List<Content>> followedContent() => get.content.followedContent();

  /// Get a Flow by its ID.
  static final getFlow = get.flow.getFlow;

  /// Gets a Flow with its Content, good for the Flow home view.
  static final getFlowAndContent = get.flow.getFlowAndContent;

  /// Post Content to a Flow.
  static final postContent = get.content.postContent;

  /// Delete Content.
  static final deleteContent = get.content.deleteContent;

  /// Edit or update Content.
  static final editContent = get.content.updateContent;
}