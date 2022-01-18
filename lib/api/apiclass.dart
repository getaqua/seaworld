import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/fragments.dart';
import 'package:seaworld/widgets/inappnotif.dart';
//import 'package:http/http.dart' as http;


abstract class APIConnect {
  String baseUrl = "";
  final Dio client;

  APIConnect(this.baseUrl) : client = Dio();

  /// Sends an HTTP GET request with the given headers to the given URL.
  Future<Response> get(String url, {Map<String, String>? headers})
  => client.get(url, options: Options(headers: headers));

  /// Sends an HTTP POST request with the given headers and body to the given URL.
  Future<Response> post(String url, {Object? body, Map<String, String>? headers})
  => client.post(url, data: body, options: Options(headers: headers));

  // @override
  // Future<GraphQLResponse<T>> query<T>(
  //   String query, {
  //   String? url,
  //   Map<String, dynamic>? variables,
  //   Map<String, String>? headers,
  // }) async {
  //   final fragments = (await _prepareFragments(query)).join("\n");
  //   final result = await super.query<T>(fragments, url: url, variables: variables, headers: headers);
  //   if (result.hasError) {
  //     handleError(result);
  //   }
  //   return result;
  // }

  // Future<List<String>> _prepareFragments(String query) async {
  //   List<String> output = [];
  //   while (true) {
  //     var _ = [...output, query].join("\n");
  //     if (_.contains("...attachment") && !output.contains(Fragments.attachment)) {
  //       output.add(Fragments.attachment); continue;
  //     }
  //     if (_.contains("...content") && !output.contains(Fragments.content)) {
  //       output.add(Fragments.content); continue;
  //     }
  //     if (_.contains("...flowPermissions") && !output.contains(Fragments.flowPermissions)) {
  //       output.add(Fragments.flowPermissions); continue;
  //     }
  //     if (_.contains("...fullFlow") && !output.contains(Fragments.fullFlow)) {
  //       output.add(Fragments.fullFlow); continue;
  //     }
  //     if (_.contains("...partialFlow") && !output.contains(Fragments.partialFlow)) {
  //       output.add(Fragments.partialFlow); continue;
  //     }
  //     break;
  //   }
  //   return [...output, query];
  // }

  // @override 
  // Future<GraphQLResponse<T>> mutation<T>(
  //   String mutation, {
  //   String? url,
  //   Map<String, dynamic>? variables,
  //   Map<String, String>? headers,
  // }) async {
  //   final result = await super.mutation<T>(mutation, url: url, variables: variables, headers: headers);
  //   if (result.hasError) {
  //     handleError(result);
  //   }
  //   return result;
  // }

  // static handleError(GraphQLResponse result) {
  //   if (kDebugMode) print(result.graphQLErrors);
  //   for (final GraphQLError error in result.graphQLErrors ?? []) {
  //     if (RegExp(r'Fragment "(.*?)" is never used.').hasMatch(error.message ?? "")) {
  //       continue;
  //     } else if (error.code == "PERMISSION_DENIED") {
  //       InAppNotification.showOverlayIn(Get.overlayContext!, InAppNotification(
  //         icon: Icon(Mdi.lockMinus),
  //         //TODO: check the permission that was missing and on what Flow
  //         title: Text("error.permissiondenied.generic".tr),
  //         corner: Corner.bottomStart,
  //       ));
  //     } else {
  //       InAppNotification.showOverlayIn(Get.overlayContext!, InAppNotification(
  //         icon: Icon(Mdi.alertCircleOutline, color: Colors.red),
  //         title: Text("crash.developererror.generic".tr),
  //         text: Text(result.graphQLErrors?.first.message ?? "Error message missing"),
  //         corner: Corner.bottomStart,
  //       ));
  //     }
  //   }
  // }

}