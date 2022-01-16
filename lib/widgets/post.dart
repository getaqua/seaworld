import 'package:file_selector/file_selector.dart';
import "package:flutter/material.dart";
import "package:get/get.dart";
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/views/richeditor.dart';
import 'package:seaworld/widgets/inappnotif.dart';
import 'package:seaworld/widgets/pfp.dart';
import 'package:seaworld/widgets/semitransparent.dart';

class NewContentCard extends StatelessWidget {
  final String? flow;
  final void Function()? refreshContent;
  final TextEditingController _controller = TextEditingController();
  final RxBool _posting = false.obs;

  NewContentCard({
    Key? key,
    this.flow,
    this.refreshContent
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
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ProfilePicture(
                    child: Config.cache.userFlow.avatarUrl != null ? NetworkImage(Config.cache.userFlow.avatarUrl!) : null,
                    size: 48, notchSize: 12,
                    fallbackChild: FallbackProfilePicture(flow: Config.cache.userFlow)
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    children: [
                      Text(Config.cache.userFlow.name, style: Get.textTheme.subtitle1),
                      Text(Config.cache.userFlow.id + " • " + "post.target.profile".tr, style: Get.textTheme.caption)
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
                  child: IconButton(onPressed: () async {
                    if (_posting.value) return;
                    _posting.update((val) => val = true);
                    var file = await API.uploadFile(file: await openFile(acceptedTypeGroups: [XTypeGroup(
                      extensions: [".png", ".jpg", ".jpeg", ".tiff", ".bmp", ".gif"],
                      label: "Images",
                      mimeTypes: ["image/png", "image/jpeg", "image/gif"],
                      webWildCards: ["image/*"]
                    )]));
                    if (file?.isOk ?? false) {
                      var resp = await API.postContent(
                        toFlow: Config.cache.userId,
                        attachments: [file?.body["url"]],
                        text: _controller.value.text
                      );
                      _posting.update((val) => val = false);
                      if (resp.isOk && resp.body["postContent"] != null) {
                        _controller.clear();
                        _cobs.update((_) => _controller);
                        // The following hack calls refreshContent if it exists,
                        // and otherwise calls a void function.
                        (refreshContent ?? (() => {}))();
                      }
                    } else {
                      // Failure!
                      _posting.update((val) => val = false);
                      InAppNotification.showOverlayIn(Get.context!, InAppNotification(
                        icon: Icon(Mdi.uploadOff, color: Colors.red),
                        title: Text("upload.failed.title".tr),
                        text: Text("upload.failed.generic".tr),
                        corner: Corner.bottomStart,
                      ));
                    }
                  }, icon: Icon(Mdi.image), color: Colors.amber)
                ),
                Tooltip(
                  message: "post.newpoll".tr,
                  child: IconButton(onPressed: null, icon: Icon(Mdi.pollBox))
                ),
                Tooltip(
                  message: "post.uploadfile".tr,
                  child: IconButton(onPressed: () async {
                    if (_posting.value) return;
                    _posting.update((val) => val = true);
                    var file = await API.uploadFile(file: await openFile());
                    if (file?.isOk ?? false) {
                      var resp = await API.postContent(
                        toFlow: Config.cache.userId,
                        attachments: [file?.body["url"]],
                        text: _controller.value.text
                      );
                      _posting.update((val) => val = false);
                      if (resp.isOk && resp.body["postContent"] != null) {
                        _controller.clear();
                        _cobs.update((_) => _controller);
                        // The following hack calls refreshContent if it exists,
                        // and otherwise calls a void function.
                        (refreshContent ?? (() => {}))();
                      }
                    } else {
                      // Failure!
                      _posting.update((val) => val = false);
                      InAppNotification.showOverlayIn(Get.context!, InAppNotification(
                        icon: Icon(Mdi.uploadOff, color: Colors.red),
                        title: Text("upload.failed.title".tr),
                        text: Text("upload.failed.generic".tr),
                        corner: Corner.bottomStart,
                      ));
                    }
                  }, icon: Icon(Mdi.file), color: Colors.pink)
                ),
                Tooltip(
                  message: "post.newevent".tr,
                  child: IconButton(onPressed: null, icon: Icon(Mdi.calendar))
                ),
                Obx(() => _posting.value ? CircularProgressIndicator(value: null)
                : _cobs.value.value.text == "" ? Tooltip(
                  message: "post.expand".tr,
                  child: IconButton(onPressed: () async {
                    await Navigator.push(context, SemiTransparentPageRoute(builder: (context) => Container(
                      alignment: Alignment.topCenter,
                      width: 720,
                      child: RichEditorPage(flow: flow))
                    ));
                    (refreshContent ?? (() => {}))();
                  }, icon: Icon(Mdi.cardBulleted), color: Get.theme.colorScheme.primary)
                ) : Tooltip(
                  message: "post.send".tr,
                  child: IconButton(
                    onPressed: !_posting.value ? () async {
                      _posting.update((val) => val = true);
                      var resp = await API.postContent(toFlow: Config.cache.userId, text: _controller.value.text);
                      _posting.update((val) => val = false);
                      if (resp.isOk && resp.body["postContent"] != null) {
                        _controller.clear();
                        _cobs.update((_) => _controller);
                        // The following hack calls refreshContent if it exists,
                        // and otherwise calls a void function.
                        (refreshContent ?? (() => {}))();
                      }
                    } : null,
                    icon: Icon(Mdi.send),
                    color: Get.theme.colorScheme.primary,
                  )
                ))
              ],
            )
          )
        ],
      ),
    );
  }
}