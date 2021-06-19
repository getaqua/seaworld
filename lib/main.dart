import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seaworld/helpers/theme.dart';
import 'package:seaworld/views/login.dart';


late final String kVersion;
late final Map<String, String> lang$en_US;

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
      initialRoute: "/login",
      translationsKeys: {
        "en_US": lang$en_US,
      },
      locale: Locale("en", "US"),
      fallbackLocale: Locale("en", "US"),
      getPages: [
        GetPage(name: "/login", page: () => const LoginView())
      ],
    );
  }
}