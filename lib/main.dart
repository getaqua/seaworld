import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Flow;
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/apierror.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/theme.dart';
import 'package:seaworld/models/flow.dart';
import 'package:seaworld/views/crash.dart';
import 'package:seaworld/views/flow/home.dart';
import 'package:seaworld/views/flow/settings/main.dart';
import 'package:seaworld/views/home/wide.dart';
import 'package:seaworld/views/login.dart';
import 'package:seaworld/views/settings/main.dart';


late final String kVersion;
late final Map<String, String> lang$en_US;
//late Map<String, Box> accounts;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadTranslations();
  kVersion = await rootBundle.loadString("assets/raw/version.txt");
  if (!kIsWeb) {
    Hive.init(
      (Platform.isAndroid ? await getApplicationDocumentsDirectory()
      : Platform.isLinux ? Directory(Platform.environment["HOME"]!) //for now
      : Platform.isWindows ? await getApplicationSupportDirectory()
      : await getLibraryDirectory())
      .path+"/.aqua-seaworld-database");
  }
  await Hive.openBox("config");
  runApp(MyApp());
}

Future<void> loadTranslations() async {
  lang$en_US = Map.castFrom(jsonDecode(await rootBundle.loadString("assets/lang/en_US.json")));
}
Future<void> reloadTranslations() async {
  Get.addTranslations({
    "en_US": Map.castFrom(jsonDecode(await rootBundle.loadString("assets/lang/en_US.json", cache: false)))
  });
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Seaworld/Aqua',
      theme: SeaworldTheme.fromConfig().data,
      color: Colors.lightBlue,
      //initialRoute: "/",
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      // translationsKeys: {
      //   "en_US": lang$en_US,
      // },
      // locale: Locale("en", "US"),
      // fallbackLocale: Locale("en", "US"),
      /* getPages: [
        GetPage(name: "/", page: () => Material(color: Colors.deepPurple[900]), middlewares: [HomeRedirect()]),
        GetPage(name: "/login", page: () => Material(child: LoginView()), middlewares: [HomeRedirect()]),
        GetPage(name: "/home", page: () =>
          API.get.isReady
            ? Config.homeLayout == HomeLayouts.wide ? WideHomeView() : Container()
            : FutureBuilder(
              future: API.get.ready,
              builder: (context, snap) => snap.connectionState == ConnectionState.done
                ? Config.homeLayout == HomeLayouts.wide ? WideHomeView() : Container()
                : Material(
                  color: Colors.black54, 
                  child: Center(child: CircularProgressIndicator(value: null)),
                )
            ),
          middlewares: [HomeRedirect()]
        ),
        GetPage(name: "/settings", page: () => SettingsRoot(), middlewares: [EnsureLoggedIn()], binding: SettingsBindings()),
        GetPage(name: "/licenses", page: () => LicensePage(applicationName: "Seaworld", applicationVersion: kVersion)),
        GetPage(name: "/flow/:id", page: () => FutureBuilder<FlowWithContent>(
          future: API.getFlowAndContent(Get.parameters["id"] ?? ""),
          builder: (context, snapshot) => snapshot.hasData ? FlowHomeView(flow: snapshot.data!)
          : snapshot.hasError && snapshot.error! is HttpException ? CrashedView(
            title: "crash.connectionerror.title".tr(),
            helptext: "crash.connectionerror.generic".tr()
          ) : snapshot.hasError ? snapshot.error! is APIErrorHandler
          ? CrashedView(
            title: (snapshot.error as APIErrorHandler).title, 
            helptext: (snapshot.error as APIErrorHandler).message
            )
          : CrashedView(helptext: snapshot.error!.toString())
          : Material(color: Colors.black54, child: Center(child: CircularProgressIndicator(value: null)))
        )),
        GetPage(name: "/flow/:id/settings", page: () => FutureBuilder<Flow>(
          future: Get.arguments is PartialFlow && Get.arguments.snowflake == Get.parameters["id"]
          ? Future.value(Get.arguments)
          : API.getFlow(Get.parameters["id"] ?? ""),
          builder: (context, snapshot) => snapshot.hasData ? FlowSettingsRoot(flow: snapshot.data!)
          : snapshot.hasError && snapshot.error! is HttpException ? CrashedView(
            title: "crash.connectionerror.title".tr(),
            helptext: "crash.connectionerror.generic".tr()
          ) : snapshot.hasError ? snapshot.error! is APIErrorHandler
          ? CrashedView(
            title: (snapshot.error as APIErrorHandler).title, 
            helptext: (snapshot.error as APIErrorHandler).message
            )
          : CrashedView(helptext: snapshot.error!.toString())
          : Material(color: Colors.black54, child: Center(child: CircularProgressIndicator(value: null)))
        ), binding: SettingsBindings())
      ],
      builder: (BuildContext context, Widget? widget) {
        Widget Function(FlutterErrorDetails? errorDetails) error = (FlutterErrorDetails? errorDetails) => Text(errorDetails?.summary.toString() ?? "Error");
        if (widget is Scaffold || widget is Navigator) {
          error = (details) => CrashedView(
            title: "View crashed",
            helptext: details?.summary.toString() ?? "This is a developer error.",
            isRenderError: true,
          );
        }
        ErrorWidget.builder = (FlutterErrorDetails errorDetails) => error(errorDetails);
        return widget ?? CrashedView(
          title: "Widget not found",
          helptext: "This is a developer error.",
          isRenderError: true,
        );
      }, */
    );
  }

  static ensureLoggedIn(GoRouterState state) {
    if (Config.token == null) {
      return "/login";
    }
  }

  final router = GoRouter(
    routes: [
      GoRoute(path: "/", redirect: (state) => Config.token == null ? "/login" : "/home"),
      GoRoute(path: "/home", builder: (context, state) => WideHomeView()),
      GoRoute(path: "/settings", builder: (context, state) => SettingsRoot()),
      GoRoute(path: "/licenses", builder: (context, state) => LicensePage(applicationName: "Seaworld", applicationVersion: kVersion)),
      GoRoute(
        path: "/flow/:flow",
        builder: (context, state) => FlowHomeView(flow: Flow.fromJSON({"snowflake": state.params["flow"]})),
        routes: [
          GoRoute(path: "settings", builder: (context, state) => FlowSettingsRoot(flow: state.extra as Flow? ?? Flow.fromJSON({"snowflake": state.params["flow"]})))
        ]
      ),
    ],
    redirect: (state) {
      if (Config.token == null && state.fullpath != "/login" && state.fullpath?.startsWith("/settings") != true) {
        return "/login";
      } else if (Config.token != null && state.fullpath == "/login") {
        if (!API.get.isReady) API.get.init(Config.token!);
        return "/home";
      }
    },
    errorPageBuilder: (context, state) => MaterialPage(child: CrashedView(
      title: "error.notfound.title".tr(),
      helptext: "error.notfound.router".tr(),
    ))
  );
}

abstract class HomeLayouts {
  static const wide = 0;
  static const dashboard = 1;
}