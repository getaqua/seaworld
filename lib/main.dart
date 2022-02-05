import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization_loader/easy_localization_loader.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Flow;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart' hide gql;
import 'package:hive/hive.dart';
import 'package:mdi/mdi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:seaworld/api/apiclass.dart';
import 'package:seaworld/api/flow.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/theme.dart';
import 'package:seaworld/models/flow.dart';
import 'package:seaworld/views/crash.dart';
import 'package:seaworld/views/flow/home.dart';
import 'package:seaworld/views/flow/settings/main.dart';
import 'package:seaworld/views/home/wide.dart';
import 'package:seaworld/views/login.dart';
import 'package:seaworld/views/settings/main.dart';
import 'package:seaworld/widgets/inappnotif.dart';


late final String kVersion;
//late Map<String, Box> accounts;

final _deadHTTPLink = HttpLink("http://127.0.0.8:900/");
bool _started = false;

ValueNotifier<GraphQLClient> gqlClient = ValueNotifier(
  GraphQLClient(
    link: _deadHTTPLink,
    cache: GraphQLCache(store: InMemoryStore())
  )
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
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
  runApp(EasyLocalization(
    supportedLocales: const [Locale("en", "US")],
    fallbackLocale: const Locale("en", "US"),
    useFallbackTranslations: true,
    path: "assets/lang",
    child: GraphQLProvider(
      client: gqlClient,
      child: ProviderScope(
        child: MyApp()
      )
    ),
  ));
}

final themeProvider = StateProvider<ThemeData>((ref) {
  return SeaworldTheme.fromConfig().data;
});

class MyApp extends ConsumerWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Seaworld/Aqua',
      theme: ref.watch(themeProvider),
      color: Colors.lightBlue,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
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

  static String? ensureLoggedIn(GoRouterState state) {
    if (Config.token == null) {
      return "/login";
    }
  }

  final router = GoRouter(
    routes: [
      //GoRoute(path: "/", redirect: (state) => Config.token == null ? "/login" : "/home"),
      GoRoute(
        path: "/",
        builder: (context, state) => API.get.isReady
          ? Config.homeLayout == HomeLayouts.wide ? WideHomeView() : Container()
          : FutureBuilder(
            future: API.get.ready,
            builder: (context, snap) => snap.connectionState == ConnectionState.done
              ? Config.homeLayout == HomeLayouts.wide ? WideHomeView() : Container()
              : snap.hasError ? (() {
                InAppNotification.showOverlayIn(context, InAppNotification(
                  icon: Icon(Mdi.alert, color: Colors.red),
                  title: Text("crash.connectionerror.title"),
                  text: Text(snap.error.toString()),
                ));
                return CrashedView(
                  title: "crash.connectionerror.title".tr(),
                  helptext: "crash.connectionerror.generic".tr(),
                );
              })() : Material(
                  color: Colors.black54, 
                  child: Center(child: CircularProgressIndicator(value: null)),
                )
        ),
        routes: [
          GoRoute(path: "settings", builder: (context, state) => SettingsRoot()),
          GoRoute(path: "licenses", builder: (context, state) => LicensePage(applicationName: "Seaworld", applicationVersion: kVersion)),
          GoRoute(
            path: "flow/:flow",
            builder: (context, state) => Query(
              options: QueryOptions(
                document: gql(FlowAPI.getFlow),
                variables: {"id": state.params["flow"]},
                fetchPolicy: FetchPolicy.cacheFirst
              ),
              builder: (result, {fetchMore, refetch}) => result.isLoading && result.data == null
              ? Material(
                color: Colors.black54, 
                child: Center(child: CircularProgressIndicator(value: null)),
              ) : result.data == null
              ? CrashedView(
                title: "crash.flow.title".tr(),
                helptext: "crash.flow.generic".tr(),
              ) : FlowHomeView(flow: Flow.fromJSON(result.data!["getFlow"]))),
            routes: [
              GoRoute(path: "settings", builder: (context, state) => state.extra != null ? FlowSettingsRoot(
                flow: state.extra as Flow
              ) : Query(
                options: QueryOptions(
                  document: gql(FlowAPI.getFlow),
                  variables: {"id": state.params["flow"]},
                  fetchPolicy: FetchPolicy.cacheFirst,
                ),
                builder: (result, {fetchMore, refetch}) => (result.data != null) ? FlowSettingsRoot(
                  flow: Flow.fromJSON(result.data!["getFlow"])
                ) : Material(
                  color: Colors.black54, 
                  child: Center(child: CircularProgressIndicator(value: null)),
                )
              ))
            ],
          ),
        ],
        redirect: ensureLoggedIn
      ),
      GoRoute(path: "/login", builder: (context, state) => Material(child: LoginView())),
    ],
    redirect: (state) {
      if (Config.token == null && state.location != "/login" && state.location.startsWith("/settings") != true) {
        return "/login";
      } else if (Config.token != null && (state.location == "/login" || state.location == "/")) {
        if (!API.get.isReady && !_started) {
          _started = true;
          API.get.init(Config.token!).then((_) => _started = false);
        }
        return state.location == "/" ? null : "/";
      }
    },
    errorPageBuilder: (context, state) => MaterialPage(child: CrashedView(
      title: "crash.notfound.title".tr(),
      helptext: "crash.notfound.generic".tr(),
      retryBack: true,
    )),
  );
}

abstract class HomeLayouts {
  static const wide = 0;
  static const dashboard = 1;
}