import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mdi/mdi.dart';

class LoginView extends StatelessWidget {

  const LoginView({
    Key? key
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Image.network("https://source.unsplash.com/daily?landscape", alignment: Alignment.center, fit: BoxFit.cover)
        ),
        Positioned(
          bottom: 0,
          top: null,
          width: Get.mediaQuery.size.width > 640 ? 640 : Get.mediaQuery.size.width,
          child: Container(
            padding: const EdgeInsets.all(4.0),
            width: Get.mediaQuery.size.width > 640 ? 640 : Get.mediaQuery.size.width,
            child: Card(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(onPressed: () => {}, child: Text("login.login".tr)),
                      )),
                      PopupMenuButton(itemBuilder: (context) => [
                        CheckedPopupMenuItem(
                          checked: false,
                          enabled: false,
                          child: Text("settings.darkmode".tr)
                        ),
                        PopupMenuItem(
                          child: Text("login.select_server".tr), 
                          onTap: () => {}
                        )
                      ]),
                    ],
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  Row(
                    children: [
                      Expanded(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: OutlinedButton(onPressed: () => {}, child: Text("login.register".tr)),
                      )),
                    ],
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                  ),
                  
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}