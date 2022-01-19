import 'dart:async';


import 'apiclass.dart';

class AuthenticationAPI extends APIConnect {
  String? token;
  String? _code;
  final String server;
  final bool isServerInsecure;
  String get urlScheme => isServerInsecure ? "http://" : "https://";
  final String clientId;
  final String? clientSecret;
  final _userReadyCompleter = Completer();

  AuthenticationAPI(this.server, this.clientId, [this.isServerInsecure = true, this.clientSecret]) : super(server);

  Stream<AuthenticationStage> login() async* {
    yield AuthenticationStage.starting;
    yield (await _getAuthCode() ? AuthenticationStage.gotCode : AuthenticationStage.failedGettingCode);
    await _userReadyCompleter.future;
    yield (await _getToken() ? AuthenticationStage.gotToken : AuthenticationStage.failedGettingToken);
  }

  Future<bool> _getAuthCode() async {
    var _response = await post(urlScheme+server+"/_gridless/authorize?client_id=$clientId&scopes=client&response_type=code");
    if (_response.statusCode != 200) {
      // Navigator.pop(context)();
      // Get.snackbar("Error", _response.statusCode.toString());
      return false;
    }
    try {
      _code = _response.data["code"];
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
    var _response = await post(urlScheme+server+"/_gridless/claimtoken?client_id=$clientId&code=$_code");
    if (_response.statusCode != 200) {
      //Navigator.pop(context)(); // move this logic to where this is received
      // TODO: report the error to the error reporter
      //Get.snackbar("Error", _response.statusCode.toString());
      return false;
    }
    try {
      token = _response.data["token"];
    } catch(e) {
      return false;
    }
    return true;
  }

  Future<bool> healthCheck() async {
    var _response = await get(urlScheme+server+"/_gridless/healthcheck");
    if (_response.statusCode != 200) {
      return false;
    }
    return _response.data == "OK";
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