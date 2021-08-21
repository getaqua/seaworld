import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/models/content.dart';
import 'package:seaworld/widgets/flowpreview.dart';

class ContentWidget extends StatefulWidget {
  final Content content;
  final bool embedded;

  const ContentWidget(this.content, {
    Key? key,
    this.embedded = false
  }) : super(key: key);

  @override
  _ContentWidgetState createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget> {
  bool _viewProfilePrompt = false;
  String? _deleted;

  @override
  Widget build(BuildContext context) {
    return _deleted == widget.content.snowflake ? Container() : Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container( // Profile
            padding: EdgeInsets.only(right: 16.0),
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.vertical(top: Radius.circular(4), bottom: Radius.zero),
            //   color: Get.theme.colorScheme.primaryVariant,
            // ),
            child: Row(
              children: [
                Tooltip(
                  message: "flow.showpreview".tr,
                  child: Container(
                    height: 48,
                    width: 48,
                    margin: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 16.0, right: 8.0),
                    alignment: Alignment.centerLeft,
                    child: Material(
                      borderRadius: BorderRadius.circular(64),
                      color: Get.theme.colorScheme.primary,
                      child: InkWell(
                        onTap: () {},
                        // onTapDown: (details) => showMenu(
                        //   context: context, 
                        //   position: RelativeRect.fromRect(
                        //     details.globalPosition & Size(40, 40), 
                        //     Offset.zero & Get.mediaQuery.size
                        //   ),
                        //   items: [
                        //     FlowPreviewPopupMenu()
                        //   ]
                        // ),
                        onTapDown: (details) => FlowPreviewPopupMenu().show(
                          context: context, 
                          flow: widget.content.author, 
                          //position: details.globalPosition & Size(40, 40)
                        ),
                        borderRadius: BorderRadius.circular(64),
                        onHover: (nv) => setState(() => _viewProfilePrompt = nv),
                        child: Stack(children: [
                          Center(child: Text("X", style: Get.textTheme.headline6)),
                          if (_viewProfilePrompt) ...[
                            Container(decoration:BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(64))),
                            Center(child: Icon(Mdi.accountBox, color: Colors.white)),
                          ],
                        ])
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Tooltip(
                    message: "flow.open".trParams({"id": widget.content.inFlowId}),
                    child: InkWell(
                      onTap: () => {},
                      child: Padding(
                        padding: EdgeInsets.only(left: 9.0, top: 16.0, bottom: 16.0, right: 16.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                children: [
                                  Text(widget.content.author.name, style: Get.textTheme.subtitle1),
                                  Text([
                                    widget.content.author.id, 
                                    if (widget.content.inFlowId != widget.content.author.id) "content.inflow".trParams({"flow": widget.content.inFlowId})
                                  ].join(" • "), style: Get.textTheme.caption)
                                ],
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                            ),
                            Expanded(child: Container()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (!widget.embedded) PopupMenuButton(
                  itemBuilder: (context) => [
                    if (widget.content.author.id == Config.cache.userId) PopupMenuItem(
                      child: Text("content.delete".tr, style: TextStyle(color: Colors.red)),
                      value: "delete"
                    )
                  ],
                  onSelected: (value) {
                    switch (value) {
                      case "delete": 
                        (() async {
                          final bool? _result = await Get.dialog(AlertDialog(
                            title: Text("content.confirmdelete.title".tr),
                            content: ContentWidget(widget.content, embedded: true),
                            actions: [
                              TextButton(onPressed: () {
                                Get.back(result: true);
                                //Get.back();
                              }, child: Text("dialog.yes".tr)),
                              TextButton(onPressed: () {
                                Get.back(result: false);
                                //Get.back();
                              }, child: Text("dialog.no".tr)),
                            ],
                          ));
                          if (_result != true) return;
                          try {
                            final _response = await API.deleteContent(snowflake: widget.content.snowflake);
                            if (_response.graphQLErrors?.isNotEmpty ?? false || _response.body["deleteContent"] != true) {
                              Get.snackbar(
                                "content.deletefailed.title".tr,
                                "content.deletefailed.message".tr,
                                duration: Duration(seconds: 10)
                              );
                            } else {
                              Get.snackbar(
                                "content.deletesuccess".tr,
                                "",
                                duration: Duration(seconds: 5)
                              );
                              setState(() => _deleted = widget.content.snowflake);
                            }
                          } catch(e) {
                            Get.snackbar(
                              "content.deletefailed.title: crash.connectionerror.title".tr,
                              "crash.connectionerror.generic".tr,
                              duration: Duration(seconds: 10)
                            );
                          }
                          Get.back();
                        })();
                        return;
                      default:
                        return;
                    }
                  }
                )
              ]
            ),
          ),
          Divider(),
          Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.topLeft,
            child: Text(widget.content.text ?? "<No text provided>")
          ),
          //Divider(),
          if (!widget.embedded) Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Tooltip(
                message: "content.like".tr,
                child: IconButton(onPressed: null, icon: Icon(Mdi.arrowUpBoldOutline))
              ),
              Tooltip(
                message: "content.dislike".tr,
                child: IconButton(onPressed: null, icon: Icon(Mdi.arrowDownBoldOutline))
              ),
              Tooltip(
                message: "content.forward".tr,
                child: IconButton(onPressed: null, icon: Icon(Mdi.syncIcon))
              ),
              Tooltip(
                message: "content.reply".tr,
                child: IconButton(onPressed: null, icon: Icon(Mdi.replyOutline))
              ),
              Expanded(child: Container()),
              Tooltip(
                message: "content.readmore".tr,
                child: IconButton(onPressed: () => {}, icon: Icon(Mdi.textBox))
              ),
            ],
          )
        ],
      ),
    );
  }
}