import 'dart:async';

import 'package:get/get_connect/connect.dart';
import 'package:seaworld/api/system.dart';
import 'package:seaworld/helpers/config.dart';

class API {
  static API get get => _instance ??= API();
  static API? _instance;
  
  late final bool isServerInsecure;
  String get urlScheme => isServerInsecure ? "http://" : "https://";
  late String token;

  Future get ready => _ready.future;
  final Completer _ready = Completer();

  /// Whether the API initialization process has completed.
  bool isReady = false;

  static bool _isLocalhost(String url) => 
    url.startsWith("localhost") 
    && (url.startsWith("localhost:") || url == "localhost");

  API();

  Future<void> init(String token, [bool? isServerInsecure]) async {
    this.isServerInsecure = isServerInsecure ?? _isLocalhost(Config.server);
    system = SystemAPI(token, urlScheme+Config.server);
    await system.getSystemInfo().then((value) {
      Config.cache.serverName = value.body["data"]["getSystemInfo"]["name"];
      Config.cache.serverVersion = value.body["data"]["getSystemInfo"]["version"];
    });
    await system.getMe().then((value) {
      Config.cache.userId = value.body["data"]["getMe"]["user"]["id"];
      Config.cache.scopes = value.body["data"]["getMe"]["tokenPermissions"];
    });
    _ready.complete();
  }
  //final _flowApi;
  late final SystemAPI system;

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
}