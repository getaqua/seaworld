import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

extension ContextExtensions on BuildContext {
  ThemeData theme() => Theme.of(this);
  TextTheme textTheme() => Theme.of(this).textTheme;
}
extension RespEx on dio.Response {
  bool get isOk => (statusCode??0) >= 200 && (statusCode??0) < 300;
}