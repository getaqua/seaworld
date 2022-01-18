import "package:flutter/material.dart";
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/models/content.dart';
import 'package:url_launcher/url_launcher.dart';

class FallbackAttachmentPreview extends StatelessWidget {
  final ContentAttachment attachment;
  final bool embedded;
  const FallbackAttachmentPreview({ Key? key, required this.attachment, this.embedded = false }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "content.attachment.download".trParams({"filename": attachment.filename}),
      child: InkWell(
        onTap: embedded ? null : () => launch(API.get.urlScheme+Config.server
        +(attachment.downloadUrl ?? attachment.url.replaceFirst("/view/", "/download/"))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(32)),
                  color: Colors.blueAccent.shade700
                ),
                child: Center(child: Icon(
                  attachment.mimeType?.startsWith("video/") ?? false ? Mdi.fileVideo
                  : attachment.mimeType?.startsWith("audio/") ?? false ? Mdi.fileMusic
                  : attachment.mimeType?.startsWith("text/") ?? false ? Mdi.fileDocument
                  //TODO: add code file icons, incl. application/json
                  : attachment.mimeType == "application/octet-stream" ? Mdi.file
                  : attachment.mimeType?.startsWith("application/") ?? false ? Mdi.fileAlert
                  : Mdi.fileQuestion,
                  color: Colors.white,
                  size: 36
                ))
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(attachment.filename, 
                  style: Get.textTheme.headline5, 
                  maxLines: 2, 
                  overflow: TextOverflow.ellipsis
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}