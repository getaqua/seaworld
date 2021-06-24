import "package:flutter/material.dart";
import "package:get/get.dart";

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
            children: [
              Text("settings.theme".tr)
            ],
          ),
        ),
      ),
    );
  }
}