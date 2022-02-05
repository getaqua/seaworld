import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:gql_dio_link/gql_dio_link.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide Response, gql;
import 'package:hive/hive.dart';
import 'package:mime_type/mime_type.dart';
import 'package:seaworld/api/apiclass.dart';
import 'package:seaworld/api/system.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/main.dart';
import 'package:seaworld/models/flow.dart';
// ignore: implementation_imports
import 'package:http_parser/src/media_type.dart';

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
    if (isReady) return;
    this.isServerInsecure = isServerInsecure ?? _isLocalhost(Config.server);
    var uri = Uri.parse(urlScheme+Config.server);
    //if (_isLocalhost(Config.server)) uri = uri.replace(host: "127.0.0.1");
    uri = uri.replace(path: "/_gridless/graphql");
    final DioLink httpLink = DioLink(
      uri.toString(),
      client: Dio(),
      defaultHeaders: {
        "Authorization": "Bearer "+token
      }
    );
    // final AuthLink authLink = AuthLink(
    //   getToken: () => 'Bearer '+token,
    // );
    final Link link = httpLink;

    gqlClient.value = GraphQLClient(
      link: link,
      cache: GraphQLCache(
        store: HiveStore(await Hive.openBox("gql")),
        dataIdFromObject: (data) {
          final typename = data['__typename'] ?? "";
          final id = data['snowflake'] ?? data['id'] ?? data['_id'];
          return id == null ? null : '$typename:$id';
        },
      ),
    );

    // system = SystemAPI(token, urlScheme+Config.server);
    // flow = FlowAPI(token, urlScheme+Config.server);
    // content = ContentAPI(token, urlScheme+Config.server);
    this.token = token;
    try {
      await gqlClient.value.query(QueryOptions(document: gql(SystemAPI.getSystemInfo), fetchPolicy: FetchPolicy.networkOnly)).then((value) {
        if (value.hasException) throw value.exception!;
        Config.cache.serverName = value.data!["getSystemInfo"]["name"];
        Config.cache.serverVersion = value.data!["getSystemInfo"]["version"];
        return value;
      });
      await gqlClient.value.query(QueryOptions(document: gql(SystemAPI.getMe), fetchPolicy: FetchPolicy.networkOnly)).then((value) {
        if (value.hasException) throw value.exception!;
        Config.cache.userId = value.data!["getMe"]["flow"]["id"];
        Config.cache.scopes = List.castFrom(value.data!["getMe"]["tokenPermissions"]);
        Config.cache.userFlow = Flow.fromJSON(value.data!["getMe"]["flow"]);
        return value;
      });
    } catch(e) {
      if (kDebugMode) {
        print(e);
      }
      _ready.completeError(e);
      isReady = false;
      return;
    }
    isReady = true;
    _ready.complete(true);
  }
  //final _flowApi;
  // late SystemAPI system;
  // late FlowAPI flow;
  // late ContentAPI content;

  static Future<Response?> uploadFile({String? fromPath, XFile? file, void Function(int, int)? sendProgress}) async {
    if (file == null && fromPath?.isNotEmpty != true) return null;
    return Dio().post(get.urlScheme+Config.server+"/_gridless/media", 
      data: FormData.fromMap({
        "file": (fromPath?.isEmpty ?? false) ? MultipartFile(File(fromPath!).openRead(),
          await File(fromPath).length(),
          filename: Uri.file(fromPath).pathSegments.last,
          contentType: MediaType.parse(mime(Uri.file(fromPath).pathSegments.last) ?? "application/octet-stream"))
          : MultipartFile(file!.openRead(), await file.length(),
          filename: file.name,
          contentType: MediaType.parse(mime(file.name) ?? "application/octet-stream"))
      }),
      options: Options(headers: {
        "Authorization": "Bearer "+get.token
      })
    ).catchError((e) {
      if (kDebugMode) print(e);
      // InAppNotification.showOverlayIn(Get.overlayContext!, InAppNotification(
      //   icon: Icon(Mdi.uploadOff, color: Colors.red),
      //   title: Text("upload.failed.title".tr()),
      //   text: Text("upload.failed.generic".tr()),
      //   corner: Corner.bottomStart,
      // ));
      throw e;
    }).then((value) {
      if ((value.statusCode ?? 0) < 200 || (value.statusCode ?? 0) >= 300) {
        if (kDebugMode) {
          print(value.data);
          print(value.statusCode);
        }
        // InAppNotification.showOverlayIn(Get.overlayContext!, InAppNotification(
        //   icon: Icon(Mdi.uploadOff, color: Colors.red),
        //   title: Text("upload.failed.title".tr()),
        //   text: Text("upload.failed.generic".tr()),
        //   corner: Corner.bottomStart,
        // ));
        return value;
      } else {
        return value;
      }
    });
  }
}