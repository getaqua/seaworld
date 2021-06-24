import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:seaworld/models/content.dart';

class ContentWidget extends StatefulWidget {
  final Content content;

  ContentWidget(this.content, {
    Key? key
  }) : super(key: key);

  @override
  _ContentWidgetState createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget> {
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
          )
        ],
      ),
    );
  }
}