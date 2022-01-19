import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/extensions.dart';
import 'package:seaworld/views/settings/about.dart';
import 'package:seaworld/views/settings/theming.dart';

class SettingsRoot extends ConsumerWidget {
  const SettingsRoot({Key? key}) : super(key: key);

  // ignore: prefer_final_fields
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      drawer: width <= 640 ? Drawer(
        child: Builder(builder: (bc) => _sidebarcontent(bc)),
      ) : null,
      appBar: AppBar(
        title: Text("settings.title".tr()),
      ),
      body: Row(
        children: [
          if (width > 640) Container(
            //margin: EdgeInsets.only(right: 32),
            width: 280,
            alignment: Alignment.topLeft,
            color: context.theme().colorScheme.primary.withAlpha(16),
            child: Builder(builder: (bc) => _sidebarcontent(bc))
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
              child: ref.watch(_settingsTabController) >= 5 ? Center(child: Icon(Mdi.alert)) : 
              [
                // GeneralSettingsPage(),
                // ThemeSettingsPage()
                Center(child: Icon(Mdi.account)),
                ThemingSettings(),
                Center(child: Icon(Mdi.security)),
                Center(child: Icon(Mdi.eye)),
                AboutPage()
              ][ref.watch(_settingsTabController)]
            ),
          ),
        ],
      )
    );
  }

  Widget _sidebarcontent(BuildContext context) {
    
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (MediaQuery.of(context).size.width <= 640) AppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              color: Theme.of(context).colorScheme.onSurface,
              onPressed: () => Navigator.of(context)..pop()..pop(),
            ),
            title: Text("settings.title".tr()),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(),
          ),
          // settings page buttons here...
          TabButton(label: "settings.account".tr(), icon: Mdi.account, index: 0, controller: _settingsTabController),
          TabButton(label: "settings.theme".tr(), icon: Mdi.palette, index: 1, controller: _settingsTabController),
          TabButton(label: "settings.security".tr(), icon: Mdi.security, index: 2, controller: _settingsTabController),
          TabButton(label: "settings.privacy".tr(), icon: Mdi.eye, index: 3, controller: _settingsTabController),
          // -----------------------------
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Divider(),
          ),
          // about, log out, licenses, legalese/compliance
          TabButton(
            icon: Mdi.information,
            label: "settings.about".tr(),
            index: 4,
            controller: _settingsTabController
          ),
          SettingsViewButton(
            icon: Mdi.lockOutline,
            label: "settings.privacypolicy".tr(),
            onPressed: () {}
          ),
          SettingsViewButton(
            icon: Mdi.textBoxOutline,
            label: "settings.tos".tr(),
            onPressed: () {}
          ),
          SettingsViewButton(
            icon: Mdi.exitToApp, 
            label: "settings.logout".tr(),
            color: Colors.red,
            onPressed: () async {
              final bool _result = await showDialog(context: context, builder: (context) => AlertDialog(
                title: Text("settings.logout".tr()),
                content: Text("settings.logout.warning".tr()),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, true), child: Text("dialog.yes".tr())),
                  TextButton(onPressed: () => Navigator.pop(context, false), child: Text("dialog.no".tr())),
                ],
              ));
              if (_result == false) return;
              Config.token = null;
              API.get.isReady = false;
              Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
            }
          ),
          // TabButton(
          //   icon: Mdi.information,
          //   label: "settings.about".tr(),
          //   index: 3
          // )
        ],
      ),
    );
  }
}

class SettingsTabController extends StateNotifier<int> {
  SettingsTabController([int page = 0]): super(page);

  void switchTo(int page) => state = page;
}

final _settingsTabController = StateNotifierProvider<SettingsTabController, int>((ref) => SettingsTabController());

class SettingsViewButton extends StatelessWidget {
  final Function() onPressed;
  final IconData icon;
  final String label;
  final Color? color;

  const SettingsViewButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.color
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.0),
      width: 240,
      child: TextButton(
        style: TextButton.styleFrom(primary: color, alignment: Alignment.centerLeft, padding: EdgeInsets.all(18.0)),
        onPressed: onPressed,
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(icon)
            ),
            Text(label),
          ],
        )
      ),
    );
  }
}

class TabButton extends ConsumerWidget {
  final String label;
  final int index;
  final IconData icon;
  final StateNotifierProvider<SettingsTabController, int> controller;

  const TabButton({
    Key? key,
    required this.label,
    required this.index,
    required this.icon,
    required this.controller,
  }): super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(4.0),
      child: (ref.watch(controller) == index) ? ElevatedButton.icon(
        onPressed: () => {},
        style: ElevatedButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.all(18.0)),
        label: Text(label, textAlign: TextAlign.left),
        icon: Icon(icon)
      ) : TextButton.icon(
        onPressed: () => ref.read(controller.notifier).switchTo(index),
        style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.all(18.0)),
        label: Text(label, textAlign: TextAlign.left),
        icon: Icon(icon)
      ),
      width: 240
    );
  }
}