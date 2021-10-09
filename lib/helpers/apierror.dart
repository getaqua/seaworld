import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class APIErrorHandler {
  static APIErrorHandler? handleError(Object? error) {
    if (error == null || (error is! Error && error is! Exception)) return null;
    // ignore: avoid_print
    if (!kReleaseMode) print(error);
    if (error is NoSuchMethodError) {
      return APIErrorHandler.error(title: "crash.notfound.title".tr, message: "crash.notfound.generic".tr);
    }
  }

  /// The translated title of the error.
  final String title;
  /// The translated description of the error.
  final String message;
  /// The original exception, for reference.
  final dynamic original;

  /// An error, as handled by the API error handler.
  APIErrorHandler.error({required this.title, required this.message, this.original});
}