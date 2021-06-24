import "package:flutter/material.dart";
import "package:get/get.dart";
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';

class NewContentCard extends StatelessWidget {
  final String? flow;
  final TextEditingController _controller = TextEditingController();
  final RxBool _posting = false.obs;

  NewContentCard({
    Key? key,
    this.flow
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _cobs = _controller.obs;
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
          Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.topLeft,
            child: Obx(() => TextField(
              decoration: InputDecoration(
                hintText: "post.newtext".tr,
                border: InputBorder.none
              ),
              controller: _controller,
              maxLines: null,
              enabled: !_posting.value,
              onChanged: (_) => _cobs.update((_) => _controller),
            ))
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
                Obx(() => _posting.value ? CircularProgressIndicator(value: null)
                : _cobs.value.value.text == "" ? Tooltip(
                  message: "post.expand".tr,
                  child: IconButton(onPressed: () => {}, icon: Icon(Mdi.cardBulleted), color: Get.theme.colorScheme.primary)
                ) : Tooltip(
                  message: "post.send".tr,
                  child: IconButton(onPressed: () async {
                    _posting.update((val) => val = true);
                    var x = await API.postContent(toFlow: Config.cache.userId, text: _controller.value.text);
                    _posting.update((val) => val = false);
                    _controller.clear();
                    _cobs.update((_) => _controller);
                  }, icon: Icon(Mdi.send), color: Get.theme.colorScheme.primary)
                ))
              ],
            )
          )
        ],
      ),
    );
  }
}