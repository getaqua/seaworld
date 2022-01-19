import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Icon, Text, Colors;
import 'package:mdi/mdi.dart';
import 'package:mime_type/mime_type.dart';
import 'package:seaworld/api/content.dart';
import 'package:seaworld/api/system.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/models/content.dart';
import 'package:seaworld/models/flow.dart';
import 'package:seaworld/views/crash.dart';
import 'package:seaworld/widgets/inappnotif.dart';
import 'package:easy_localization/easy_localization.dart';
// ignore: implementation_imports
import 'package:http_parser/src/media_type.dart';

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
        Config.cache.userId = value.body["getMe"]["flow"]["id"];
        Config.cache.scopes = List.castFrom(value.body["getMe"]["tokenPermissions"]);
        Config.cache.userFlow = Flow.fromJSON(value.body["getMe"]["flow"]);
      });
      isReady = true;
      _ready.complete(true);
    } catch(e) {
      rethrow;
      // Get.off(() => CrashedView(
      //   title: "crash.connectionerror.title".tr(),
      //   helptext: e.toString().contains('[]("errors")')
      //   ? "crash.connectionerror.generic".tr()
      //   : e.toString()
      // ));
    }
  }
  //final _flowApi;
  late SystemAPI system;
  late FlowAPI flow;
  late ContentAPI content;

  static Future<Response?> uploadFile({String? fromPath, XFile? file}) async {
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
      InAppNotification.showOverlayIn(Get.overlayContext!, InAppNotification(
        icon: Icon(Mdi.uploadOff, color: Colors.red),
        title: Text("upload.failed.title".tr()),
        text: Text("upload.failed.generic".tr()),
        corner: Corner.bottomStart,
      ));
    }).then((value) {
      if ((value.statusCode ?? 0) < 200 || (value.statusCode ?? 0) >= 300) {
        if (kDebugMode) {
          print(value.data);
          print(value.statusCode);
        }
        InAppNotification.showOverlayIn(Get.overlayContext!, InAppNotification(
          icon: Icon(Mdi.uploadOff, color: Colors.red),
          title: Text("upload.failed.title".tr()),
          text: Text("upload.failed.generic".tr()),
          corner: Corner.bottomStart,
        ));
        return value;
      } else {
        return value;
      }
    });
  }
}