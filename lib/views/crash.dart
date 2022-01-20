import 'package:easy_localization/easy_localization.dart';
import "package:flutter/material.dart";
import 'package:go_router/go_router.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/extensions.dart';

class CrashedView extends StatefulWidget {
  final String? title;
  final String helptext;
  final bool isRenderError;
  final bool retryBack;

  const CrashedView({
    Key? key,
    this.title,
    required this.helptext,
    this.isRenderError = false,
    this.retryBack = false
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
          child: Container(color: widget.isRenderError ? Colors.red.shade900.withOpacity(0.87) : Colors.black87),
        ),
        Positioned.fill(
          child: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                //Empty state image
                if (!widget.isRenderError || widget.title != null) Text(widget.title ?? "crash.generic.title".tr(), style: context.textTheme().headline4?.copyWith(color: Colors.white)),
                Text(widget.helptext, style: context.textTheme().bodyText2?.copyWith(color: Colors.white)),
                if (!widget.isRenderError) Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => widget.retryBack
                          ? Navigator.canPop(context) ? context.pop() : context.go("/")
                          : context.go("/"),
                        child: widget.retryBack
                          ? Text("crash.goback".tr())
                          : Text("crash.tryagain".tr())
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Config.token = null;
                          API.get.reset();
                          Navigator.popAndPushNamed(context, "/login");
                        },
                        child: Text("settings.logout".tr()),
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