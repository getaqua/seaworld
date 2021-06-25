import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/models/content.dart';
import 'package:seaworld/widgets/flowpreview.dart';

class ContentWidget extends StatefulWidget {
  final Content content;

  ContentWidget(this.content, {
    Key? key
  }) : super(key: key);

  @override
  _ContentWidgetState createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget> {
  bool _viewProfilePrompt = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Container( // Profile
            padding: EdgeInsets.only(right: 16.0),
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.vertical(top: Radius.circular(4), bottom: Radius.zero),
            //   color: Get.theme.colorScheme.primaryVariant,
            // ),
            child: Row(
              children: [
                Container(
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
                      onHover: (nv) => _viewProfilePrompt = nv,
                      child: Stack(children: [
                        if (_viewProfilePrompt) ...[
                          Center(child: Icon(Mdi.account, color: Colors.white)),
                          Material(color: Colors.black54)
                        ],
                        Center(child: Text("X", style: Get.textTheme.headline6)),
                      ])
                    ),
                  ),
                ),
                Expanded(
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
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(child: Text("settings.tos".tr, style: Get.textTheme.overline))
                  ],
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
          Row(
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