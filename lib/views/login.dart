import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/main.dart';
import '../api/auth.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginView extends StatefulWidget {

  const LoginView({
    Key? key
  }) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  AuthenticationAPI? _api;
  // ignore: prefer_final_fields
  String _serverUrl = "localhost:3000";
  // ignore: prefer_final_fields
  String _clientId = "AQUA-4c6fe156afbd511f4e8e5ecb3606adabb7bba61c155e78bf2501c5cf59d3563bfcfede04";

  @override
  Widget build(BuildContext context) {
    if (_api == null || _api?.server != _serverUrl) _api = AuthenticationAPI(_serverUrl, _clientId);
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Image.network("https://source.unsplash.com/daily?landscape", alignment: Alignment.center, fit: BoxFit.cover)
        ),
        Positioned(
          bottom: 0,
          top: null,
          width: Get.mediaQuery.size.width > 640 ? 640 : Get.mediaQuery.size.width,
          child: Container(
            padding: const EdgeInsets.all(4.0),
            width: Get.mediaQuery.size.width > 640 ? 640 : Get.mediaQuery.size.width,
            child: Column(
              children: [
                Row(
                  children: [
                    FutureBuilder(
                      future: _api?.healthCheck(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data == true) {
                          return Container();
                        } else if (snapshot.hasError || (snapshot.hasData && snapshot.data == false)) {
                          return IconButton(
                            onPressed: () => Get.snackbar(
                              "Connection error",
                              "Cannot reach server ($_serverUrl)",
                              duration: Duration(seconds: 10),
                              isDismissible: true
                            ),
                            icon: Icon(Mdi.alert, color: Colors.red)
                          );
                        } else {
                          return IconButton(
                            onPressed: () => {},
                            icon: Icon(Mdi.connection, color: Colors.yellow)
                          );
                        }
                      }
                    )
                  ],
                ),
                Card(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_api == null) return Get.snackbar("Cannot login", "Server not selected");
                                await for (var stage in _api!.login()) {
                                  switch (stage) {
                                    case AuthenticationStage.starting:
                                      Get.dialog(Center(child: CircularProgressIndicator(value: null)), barrierDismissible: false);
                                      break;
                                    case AuthenticationStage.gotCode:
                                      launch(_api!.authorizationUrl()!);
                                      await Get.defaultDialog(title: "Waiting for you", middleText: "Login to the app, and press OK when you're done.", textConfirm: "OK");
                                      _api!.userReady();
                                      break;
                                    case AuthenticationStage.gotToken:
                                      Get.back();
                                      Config.token = _api!.token;
                                      Get.offAndToNamed("/home");
                                      break;
                                    default:
                                  }
                                }
                              }, // Login requires something much more elaborate than registration
                              child: Text("login.login".tr)
                            ),
                          )),
                          PopupMenuButton(itemBuilder: (context) => [
                            CheckedPopupMenuItem(
                              checked: false,
                              enabled: false,
                              child: Text("settings.darkmode".tr)
                            ),
                            PopupMenuItem(
                              child: Text("login.select_server".tr), 
                              onTap: () => {}
                            )
                          ]),
                        ],
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      Row(
                        children: [
                          Expanded(child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: OutlinedButton(
                              onPressed: () => _api != null ? launch(_api!.urlScheme+_serverUrl+"/_gridless/register", forceWebView: true, enableJavaScript: true) : {},
                              child: Text("login.register".tr)
                            ),
                          )),
                        ],
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}