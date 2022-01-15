import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/widgets/inappnotif.dart';

abstract class APIConnect extends GetConnect {
  @override 
  Future<GraphQLResponse<T>> query<T>(
    String query, {
    String? url,
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
  }) async {
    final result = await super.query<T>(query, url: url, variables: variables, headers: headers);
    if (result.hasError) {
      handleError(result);
    }
    return result;
  }

  @override 
  Future<GraphQLResponse<T>> mutation<T>(
    String mutation, {
    String? url,
    Map<String, dynamic>? variables,
    Map<String, String>? headers,
  }) async {
    final result = await super.mutation<T>(mutation, url: url, variables: variables, headers: headers);
    if (result.hasError) {
      handleError(result);
    }
    return result;
  }

  static handleError(GraphQLResponse result) {
    if (kDebugMode) print(result.graphQLErrors);
    if (result.graphQLErrors?.first.code == "PERMISSION_DENIED") {
      InAppNotification.showOverlayIn(Get.overlayContext!, InAppNotification(
        icon: Icon(Mdi.lockMinus),
        //TODO: check the permission that was missing and on what Flow
        title: Text("error.permissiondenied.generic".tr),
        corner: Corner.bottomStart,
      ));
    } else {
      InAppNotification.showOverlayIn(Get.overlayContext!, InAppNotification(
        icon: Icon(Mdi.alertCircleOutline, color: Colors.red),
        title: Text("crash.developererror.generic".tr),
        text: Text(result.graphQLErrors?.first.message ?? "Error message missing"),
        corner: Corner.bottomStart,
      ));
    }
  }

}