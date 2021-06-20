import 'dart:async';

import 'package:get/get.dart';
import 'package:get/get_connect/connect.dart';

class AuthenticationAPI extends GetConnect {
  String? token;
  String? _code;
  final String server;
  final bool isServerInsecure;
  String get urlScheme => isServerInsecure ? "http://" : "https://";
  final String clientId;
  final String? clientSecret;
  final _userReadyCompleter = Completer();

  AuthenticationAPI(this.server, this.clientId, [this.isServerInsecure = true, this.clientSecret]);

  Stream<AuthenticationStage> login() async* {
    yield AuthenticationStage.starting;
    yield (await _getAuthCode() ? AuthenticationStage.gotCode : AuthenticationStage.failedGettingCode);
    await _userReadyCompleter.future;
    yield (await _getToken() ? AuthenticationStage.gotToken : AuthenticationStage.failedGettingToken);
  }

  Future<bool> _getAuthCode() async {
    var _response = await post(urlScheme+server+"/_gridless/authorize?client_id=$clientId&scopes=client&response_type=code", null);
    if (_response.statusCode != 200) {
      Get.back();
      Get.snackbar("Error", _response.statusText ?? _response.statusCode?.toString() ?? "Unknown error");
      return false;
    }
    try {
      _code = _response.body["code"];
    } catch(e) {
      return false;
    }
    return true;
  }
  String? authorizationUrl() => _code != null ? urlScheme+server+"/_gridless/authorize?client_id=$clientId&code=$_code&grant_type=code" : null;
  void userReady() {
    _userReadyCompleter.complete();
  }
  Future<bool> _getToken() async {
    var _response = await post(urlScheme+server+"/_gridless/claimtoken?client_id=$clientId&code=$_code", null);
    if (_response.statusCode != 200) {
      Get.back();
      Get.snackbar("Error", _response.statusText ?? _response.statusCode?.toString() ?? "Unknown error");
      return false;
    }
    try {
      token = _response.body["token"];
    } catch(e) {
      return false;
    }
    return true;
  }
}

enum AuthenticationStage {
  starting,
  gotCode,
  failedGettingCode,
  //waitingOnUserAuthorization,
  gotToken,
  failedGettingToken
}