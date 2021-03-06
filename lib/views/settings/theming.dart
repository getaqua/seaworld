import 'package:easy_localization/easy_localization.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/extensions.dart';
import 'package:seaworld/main.dart';

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
              Consumer(
                builder: (context, ref, _) => SwitchListTile(
                  value: Config.darkmode,
                  onChanged: (nv) {
                    Config.darkmode = nv;
                    // Get.changeTheme(SeaworldTheme.fromConfig().data);
                    // Get.forceAppUpdate();
                    // ^^^ this is necessary to apply the theme change
                    ref.refresh(themeProvider);
                  },
                  title: Text("settings.darkmode".tr())
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}