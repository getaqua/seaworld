import 'package:hive/hive.dart';
import 'package:seaworld/main.dart' show HomeLayouts;

class Config {
  static Config get _self => _$inst ??= Config();
  static Config? _$inst;
  final Box box = Hive.box("config");

  static _CachedValues get cache => _self._cache ??= _CachedValues();
  _CachedValues? _cache;

  /// Whether the user has engaged darkmode.
  static bool get darkmode => _self.box.get("darkmode", defaultValue: true);
  static set darkmode(bool v) => _self.box.put("darkmode", v);
  /// Which layout the user is using. From [HomeLayouts].
  static int get homeLayout => _self.box.get("homelayout", defaultValue: 0);
  static set homeLayout(int v) => _self.box.put("homelayout", v);
  /// The user's token. The app is currently built for only one user at a time.
  static String? get token => _self.box.get("token");
  static set token(String? v) => _self.box.put("token", v);
  /// The user's selected server. Should be the Aqua server, but for testing,
  /// development, and (for now) enterprise deployments, this is necessary.
  static String get server => _self.box.get("server", defaultValue: "localhost:3000");
  static set server(String v) => _self.box.put("server", v);
}

class _CachedValues {
  /// The server's display name.
  String serverName = "Untitled server!!";
  /// The server's reported (software and) version.
  String serverVersion = "v0.0.0-null.0";
  /// The user ID.
  String userId = "example.net//user";
  /// The scopes granted to the client.
  List<String> scopes = [];
}