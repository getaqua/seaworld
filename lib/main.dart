import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/theme.dart';
import 'package:seaworld/views/home/wide.dart';
import 'package:seaworld/views/login.dart';


late final String kVersion;
late final Map<String, String> lang$en_US;
//late Map<String, Box> accounts;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  lang$en_US = Map.castFrom(jsonDecode(await rootBundle.loadString("assets/lang/en_US.json")));
  kVersion = await rootBundle.loadString("assets/raw/version.txt");
  if (!kIsWeb) {
    Hive.init(
      (Platform.isAndroid ? await getApplicationDocumentsDirectory()
      : Platform.isLinux ? Directory(Platform.environment["HOME"]!) //for now
      : await getLibraryDirectory())
      .path+"/.aqua-seaworld-database");
  }
  await Hive.openBox("config");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Seaworld/Aqua',
      theme: SeaworldTheme().data,
      color: Colors.lightBlue,
      initialRoute: "/",
      translationsKeys: {
        "en_US": lang$en_US,
      },
      locale: Locale("en", "US"),
      fallbackLocale: Locale("en", "US"),
      getPages: [
        GetPage(name: "/", page: () => Material(color: Colors.deepPurple[900]), middlewares: [HomeRedirect()]),
        GetPage(name: "/login", page: () => const LoginView(), middlewares: [HomeRedirect()]),
        GetPage(name: "/home", page: () =>
          API.get.isReady
            ? Config.homeLayout == HomeLayouts.wide ? WideHomeView() : Container()
            : FutureBuilder(
              future: API.get.ready,
              builder: (context, snap) => snap.connectionState == ConnectionState.done
                ? Config.homeLayout == HomeLayouts.wide ? WideHomeView() : Container()
                : Material(
                  color: Colors.black, 
                  child: CircularProgressIndicator(value: null),
                )
            ),
          middlewares: [HomeRedirect()]
        )
      ],
    );
  }
}

class HomeRedirect extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (Config.token == null && route != "/login") {
      return RouteSettings(name: "/login");
    } else if (Config.token != null && route != "/home") {
      API.get.init(Config.token!);
      return RouteSettings(name: "/home");
    }
  }
}
class EnsureLoggedIn extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (Config.token == null) {
      return RouteSettings(name: "/login");
    }
  }
}

abstract class HomeLayouts {
  static const wide = 0;
  static const dashboard = 1;
}