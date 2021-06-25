import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';

class CrashedView extends StatefulWidget {
  final String? title;
  final String helptext;
  final bool isRenderError;

  const CrashedView({
    Key? key,
    this.title,
    required this.helptext,
    this.isRenderError = false
  }) : super(key: key);

  @override
  _CrashedViewState createState() => _CrashedViewState();
}

class _CrashedViewState extends State<CrashedView> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Image.asset("assets/img/static.gif", alignment: Alignment.center, fit: BoxFit.cover)
        ),
        Positioned.fill(
          child: Container(color: widget.isRenderError ? Colors.red.withOpacity(0.87) : Colors.black87),
        ),
        Positioned.fill(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                //Empty state image
                if (!widget.isRenderError || widget.title != null) Text(widget.title ?? "crash.generic.title".tr, style: Get.textTheme.headline4?.copyWith(color: Colors.white)),
                Text(widget.helptext, style: Get.textTheme.bodyText2?.copyWith(color: Colors.white)),
                if (!widget.isRenderError) Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => Get.offNamed("/"), 
                        child: Text("crash.tryagain".tr)
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Config.token = "";
                          API.get.isReady = false;
                          Get.offAllNamed("/");
                        }, 
                        child: Text("settings.logout".tr),
                        style: ElevatedButton.styleFrom(primary: Colors.red),
                      )
                    )
                  ]
                )
              ]
            )
          )
        )
      ]
    );
  }
}