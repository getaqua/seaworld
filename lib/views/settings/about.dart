import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import "package:get/get.dart";
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/theme.dart';
import 'package:seaworld/main.dart';
import 'package:seaworld/views/crash.dart';

// ignore: use_key_in_widget_constructors
class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text("Seaworld", style: Get.textTheme.headline2),
              Text(kVersion, style: Get.textTheme.headline6),
              Padding(
                padding: EdgeInsets.all(8),
                child: SingleChildScrollView(child: Column(children: [
                  ListTile(
                    onTap: () => Get.toNamed("/licenses"), 
                    title: Text("Open-source licenses")
                  ),
                  if (!kReleaseMode) ListTile(
                    onTap: () => Get.to(CrashedView(
                      title: "crash.generic.title".tr, 
                      helptext: "crash.developererror.generic".tr,
                      retryBack: true,
                    )), 
                    title: Text("Test crash!")
                  ),
                ]))
              )
            ]
          )
        )
      )
    );
  }
}