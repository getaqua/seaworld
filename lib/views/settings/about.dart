import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:go_router/go_router.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/helpers/extensions.dart';
import 'package:seaworld/main.dart';
import 'package:seaworld/views/crash.dart';
import 'package:seaworld/widgets/inappnotif.dart';
import 'package:url_launcher/url_launcher.dart';

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
              Text("Seaworld", style: context.textTheme().headline2),
              Text(kVersion, style: context.textTheme().headline6),
              Padding(
                padding: EdgeInsets.all(8),
                child: SingleChildScrollView(child: Column(children: [
                  ListTile(
                    leading: Icon(Mdi.github),
                    onTap: () => launch("https://github.com/getaqua/seaworld/"), 
                    title: Text("about.sourcelink".tr())
                  ),
                  ListTile(
                    leading: Icon(Mdi.license),
                    onTap: () => context.go("/licenses"), 
                    title: Text("about.licenses".tr())
                  ),
                  if (!kReleaseMode) ...[
                    ListTile(
                      leading: Icon(Mdi.translate),
                      onTap: () async {
                        EasyLocalization.of(context)?.delegate.load(EasyLocalization.of(context)!.locale);
                      },
                      title: Text("Reload translations")
                    ),
                    ListTile(
                      leading: Icon(Mdi.alertCircleOutline),
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CrashedView(
                        title: "crash.generic.title".tr(), 
                        helptext: "crash.developererror.generic".tr(),
                        retryBack: true,
                      ))), 
                      title: Text("Test crash!")
                    ),
                    ListTile(
                      leading: Icon(Mdi.bellAlert),
                      onTap: () => InAppNotification.showOverlayIn(context, InAppNotification(
                        title: Text("System message"),
                        text: Text("This is a test message. With all due respect, Sir, I think we should go this way."),
                        icon: Icon(Mdi.spiderWeb, color: Colors.amber),
                        corner: Corner.bottomStart,
                      )),
                      title: Text("Test in-app notification")
                    ),
                    ListTile(
                      leading: Icon(Mdi.fileTree),
                      onTap: () async {
                        final TextEditingController controller = TextEditingController(text: GoRouter.of(context).location);
                        final res = await showDialog<String?>(context: context, builder: (context) => AlertDialog(
                          title: Text("Go where?"),
                          content: TextField(
                            controller: controller,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            )
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: Text("dialog.cancel")),
                            TextButton(onPressed: () => Navigator.pop(context, controller.value.text), child: Text("dialog.ok")),
                          ],
                        ));
                        if (res == null) return;
                        context.go(res);
                      },
                      title: Text("Navigate")
                    ),
                  ]
                ]))
              )
            ]
          )
        )
      )
    );
  }
}