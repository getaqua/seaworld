import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/theme.dart';
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
  late AuthenticationAPI _api;
  // ignore: prefer_final_fields
  String _serverUrl = "localhost:3000";
  // ignore: prefer_final_fields
  String _clientId = "AQUA-e7a4b74f08be3f4181dc6c9ee162d5839071f3ac298ddd0195dcbb70b2cdf74c4358bbbc";
  late final Rx<Future<bool>> _healthCheckFuture;

  @override
  void initState() {
    super.initState();
    _api = AuthenticationAPI(_serverUrl, _clientId);
    _healthCheckFuture = _api.healthCheck().obs;
  }

  @override
  Widget build(BuildContext context) {
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
                    Obx(() => FutureBuilder(
                      future: _healthCheckFuture.value,
                      builder: (context, snapshot) {
                        if (snapshot.data == true) {
                          return Container();
                        } else if (snapshot.hasError || (snapshot.hasData && snapshot.data == false)) {
                          return IconButton(
                            onPressed: () => Get.snackbar(
                              "login.connectionerror".tr,
                              "login.cannotreach".trParams({"url": _api.server}),
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.grey[900],
                              colorText: Colors.white,
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
                    )),
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
                                //if (_api == null) return Get.snackbar("Cannot login", "Server not selected");
                                await for (var stage in _api.login()) {
                                  switch (stage) {
                                    case AuthenticationStage.starting:
                                      Get.dialog(Center(child: CircularProgressIndicator(value: null)), barrierDismissible: false);
                                      break;
                                    case AuthenticationStage.gotCode:
                                      launch(_api.authorizationUrl()!);
                                      //await Get.defaultDialog(title: "Waiting for you", middleText: "Login to the app, and press OK when you're done.", textConfirm: "OK");
                                      await Get.dialog(AlertDialog(
                                        title: Text("login.authorizing.title".tr),
                                        content: Text("login.authorizing.message".tr),
                                        actions: [
                                          TextButton(onPressed: () => Get.back(), child: Text("dialog.ok".tr)),
                                        ],
                                      ));
                                      _api.userReady();
                                      break;
                                    case AuthenticationStage.gotToken:
                                      Get.back();
                                      Config.token = _api.token;
                                      Config.server = _serverUrl;
                                      API.get.reset();
                                      API.get.init(Config.token!);
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
                            PopupMenuItem(
                              enabled: true,
                              padding: EdgeInsets.all(0),
                              child: CheckboxListTile(
                                value: Config.darkmode,
                                onChanged: (nv) {
                                  Config.darkmode = nv ?? Config.darkmode;
                                  Get.changeTheme(SeaworldTheme.fromConfig().data);
                                  Get.forceAppUpdate(); 
                                  // ^^^ this is necessary to apply the theme change
                                  Get.back();
                                },
                                title: Text("settings.darkmode".tr)
                              )
                            ),
                            PopupMenuItem(
                              child: Text("login.selectserver".tr), 
                              value: 10
                            )
                          ], onSelected: (value) async {
                            if (value == 10) { //Select Server selected
                              final _urlController = TextEditingController(text: Config.server);
                              final _keyController = TextEditingController();
                              var _newClientId = "";
                              var _newServerUrl = "";
                              final _result = await showDialog<bool>(context: context, builder: (context) => Dialog(
                                child: Container(
                                  width: 480,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("login.selectserver".tr, style: Get.textTheme.headline5, textAlign: TextAlign.start),
                                      Text("login.selectserver.message".tr, style: Get.textTheme.bodyText2),
                                      SizedBox(
                                        width: 480,
                                        child: TextField(
                                          controller: _urlController,
                                          decoration: InputDecoration(
                                            labelText: "Server URL"
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 480,
                                        child: TextField(
                                          controller: _keyController,
                                          decoration: InputDecoration(
                                            labelText: "Client ID"
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: SizedBox(
                                          height: 480,
                                          width: 480,
                                          child: ListView(
                                            children: [
                                              ListTile(
                                                selected: _serverUrl == "localhost:3000",
                                                title: Text("Local Development"),
                                                onTap: () {
                                                  _newClientId = _keyController.value.text == ""
                                                  ? "AQUA-e7a4b74f08be3f4181dc6c9ee162d5839071f3ac298ddd0195dcbb70b2cdf74c4358bbbc"
                                                  : _keyController.value.text;
                                                  _newServerUrl = "http://localhost:3000";
                                                },
                                              ),
                                              ListTile(
                                                selected: _serverUrl == "coruscant-aqua-server.example",
                                                title: Text("Coruscant"),
                                                onTap: () {
                                                  _newClientId = "AQUA-INVALID";
                                                  _newServerUrl = "https://coruscant-aqua-server.example";
                                                },
                                              ),
                                              ListTile(title: Text("Naboo"), onTap: () {}),
                                              ListTile(title: Text("Naboo"), onTap: () {}),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Flex(direction: Axis.horizontal,  children: [
                                        Expanded(child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: OutlinedButton(onPressed: () => Get.back(result: false), child: Text("dialog.cancel".tr)),
                                        )),
                                        Expanded(child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(onPressed: () => Get.back(result: true), child: Text("dialog.apply".tr)),
                                        )),
                                      ])
                                    ],
                                  ),
                                ),
                              ));
                              // apply choices, if the dialog was Applied
                              if (_result == true && _newServerUrl != "") {
                                final _uri = Uri.parse(_newServerUrl);
                                _serverUrl = _uri.authority;
                                _clientId = _newClientId;
                                _api = AuthenticationAPI(_serverUrl, _clientId, !_uri.scheme.startsWith("https"));
                                _healthCheckFuture.update((_) => _api.healthCheck().obs);
                                setState(() {});
                              } else if (_result == true) {
                                setState(() {});
                              }
                            }
                          },),
                        ],
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                      Row(
                        children: [
                          Expanded(child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: OutlinedButton(
                              onPressed: () => launch(_api.urlScheme+_serverUrl+"/_gridless/register", forceWebView: true, enableJavaScript: true),
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