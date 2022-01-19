import 'package:easy_localization/src/public_ext.dart';
import "package:flutter/material.dart";
import "package:get/get.dart";
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/extensions.dart';
import 'package:seaworld/helpers/theme.dart';

// ignore: use_key_in_widget_constructors
class ThemingSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("settings.theme".tr(), style: context.textTheme().subtitle1),
              SizedBox(height: 16),
              SwitchListTile(
                value: Config.darkmode,
                onChanged: (nv) {
                  Config.darkmode = nv;
                  Get.changeTheme(SeaworldTheme.fromConfig().data);
                  Get.forceAppUpdate();
                  // ^^^ this is necessary to apply the theme change
                },
                title: Text("settings.darkmode".tr())
              ),
            ],
          ),
        ),
      ),
    );
  }
}