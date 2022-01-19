import 'package:easy_localization/src/public_ext.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/views/settings/about.dart';
import 'package:seaworld/views/settings/theming.dart';

class SettingsRoot extends GetView<SettingsTabController> {
  // ignore: prefer_final_fields
  
  @override
  Widget build(BuildContext context) {
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
            color: Get.theme.colorScheme.primary.withAlpha(16),
            child: Builder(builder: (bc) => _sidebarcontent(bc))
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
              child: Obx(() => controller.index.value >= 5 ? Center(child: Icon(Mdi.alert)) : 
                [
                  // GeneralSettingsPage(),
                  // ThemeSettingsPage()
                  Center(child: Icon(Mdi.account)),
                  ThemingSettings(),
                  Center(child: Icon(Mdi.security)),
                  Center(child: Icon(Mdi.eye)),
                  AboutPage()
                ][controller.index.value]
              ),
            ),
          )
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
          TabButton(label: "settings.account".tr(), icon: Mdi.account, index: 0),
          TabButton(label: "settings.theme".tr(), icon: Mdi.palette, index: 1),
          TabButton(label: "settings.security".tr(), icon: Mdi.security, index: 2),
          TabButton(label: "settings.privacy".tr(), icon: Mdi.eye, index: 3),
          // -----------------------------
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Divider(),
          ),
          // about, log out, licenses, legalese/compliance
          TabButton(
            icon: Mdi.information,
            label: "settings.about".tr(),
            index: 4
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
              final bool _result = await Get.dialog(AlertDialog(
                title: Text("settings.logout".tr()),
                content: Text("settings.logout.warning".tr()),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context)(result: true), child: Text("dialog.yes".tr())),
                  TextButton(onPressed: () => Navigator.pop(context)(result: false), child: Text("dialog.no".tr())),
                ],
              ));
              if (_result == false) return;
              Config.token = null;
              API.get.isReady = false;
              Get.offAllNamed("/");
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

class SettingsTabController extends GetxController {
  RxInt index = (0).obs;
  //int index = 0;
  void switchTo(int newIndex) {
    //index.update((val) => newIndex);
    index.value = newIndex;
    update();
  }
}
class SettingsBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsTabController>(() => SettingsTabController());
  }
}

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

class TabButton extends StatelessWidget {
  final String label;
  final int index;
  final IconData icon;
  final SettingsTabController? tabController;

  const TabButton({
    Key? key,
    required this.label,
    required this.index,
    required this.icon,
    this.tabController,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = tabController ?? Get.find<SettingsTabController>();
    return Container(
      padding: EdgeInsets.all(4.0),
      child: Obx(() => (controller.index.value == index) ? ElevatedButton.icon(
        onPressed: () => {},
        style: ElevatedButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.all(18.0)),
        label: Text(label, textAlign: TextAlign.left),
        icon: Icon(icon)
      ) : TextButton.icon(
        onPressed: () {controller.switchTo(index); controller.update();},
        style: TextButton.styleFrom(alignment: Alignment.centerLeft, padding: EdgeInsets.all(18.0)),
        label: Text(label, textAlign: TextAlign.left),
        icon: Icon(icon)
      )),
      width: 240
    );
  }
}