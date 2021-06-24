import "package:flutter/material.dart";
import "package:get/get.dart";
import 'package:mdi/mdi.dart';
import 'package:seaworld/helpers/config.dart';

class NewContentCard extends StatelessWidget {
  final String? flow;

  const NewContentCard({
    Key? key,
    this.flow
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container( // Profile
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  margin: EdgeInsets.only(right: 16.0),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(64),
                    color: Get.theme.colorScheme.primary,
                    //image: DecorationImage(image: NetworkImage(widget.content.avatarUrl))
                  ),
                  child: Center(child: Text("X", style: Get.textTheme.headline6)),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: [
                      Text(Config.cache.userId, style: Get.textTheme.subtitle1),
                      Text(Config.cache.userId + " • " + "post.target.profile".tr, style: Get.textTheme.caption)
                    ],
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ),
                // Expanded(child: Container()),
                // PopupMenuButton(
                //   itemBuilder: (context) => [
                //     PopupMenuItem(child: Text("settings.tos".tr, style: Get.textTheme.overline))
                //   ],
                // )
              ]
            ),
          ),
          Divider(),
          InkWell(
            onTap: null,
            child: Container(
              padding: EdgeInsets.all(16.0),
              alignment: Alignment.topLeft,
              child: Text("post.newtext".tr)
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.topLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Tooltip(
                  message: "post.newimage".tr,
                  child: IconButton(onPressed: null, icon: Icon(Mdi.image))
                ),
                Tooltip(
                  message: "post.newpoll".tr,
                  child: IconButton(onPressed: null, icon: Icon(Mdi.pollBox))
                ),
                Tooltip(
                  message: "post.uploadfile".tr,
                  child: IconButton(onPressed: null, icon: Icon(Mdi.file))
                ),
                Tooltip(
                  message: "post.newevent".tr,
                  child: IconButton(onPressed: null, icon: Icon(Mdi.calendar))
                ),
                Tooltip(
                  message: "post.send".tr,
                  child: IconButton(onPressed: () => {}, icon: Icon(Mdi.send), color: Get.theme.colorScheme.primary)
                )
              ],
            )
          )
        ],
      ),
    );
  }
}