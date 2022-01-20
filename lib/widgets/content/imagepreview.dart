import 'package:easy_localization/easy_localization.dart';
import "package:flutter/material.dart";
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/extensions.dart';
import 'package:seaworld/models/content.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageAttachmentPreview extends StatefulWidget {
  final ContentAttachment attachment;
  const ImageAttachmentPreview({ Key? key, required this.attachment }) : super(key: key);

  @override
  State<ImageAttachmentPreview> createState() => _ImageAttachmentPreviewState();
}

class _ImageAttachmentPreviewState extends State<ImageAttachmentPreview> {
  bool _hovering = false;
  bool _errored = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (e) => setState(() => _hovering = true),
      onExit: (e) => setState(() => _hovering = false),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Material(
            color: _hovering && !_errored ? Colors.black12 : Colors.transparent,
            child: InkWell(
              onTapDown: (_) {},
              child: Image.network(
                API.get.urlScheme+Config.server+widget.attachment.url,
                fit: BoxFit.scaleDown, //experiment with this, maybe
                errorBuilder: (context, error, st) {
                  _errored = true;
                  var message = error.toString();
                  if (error is NetworkImageLoadException) {
                    if (error.statusCode == 404) {
                      message = "Image deleted";
                    } else {
                      message = "An unknown error occurred while loading the image";
                    }
                  }
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(Mdi.imageBroken, color: Colors.orange),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(message, style: TextStyle(color: Colors.orange)),
                        ),
                      )
                    ],
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                  );
                }
              ),
            ),
          ),
          if (_hovering && !_errored) Positioned.directional(
            textDirection: Directionality.of(context),
            top: 0,
            end: 0,
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(24)),
                        child: Tooltip(
                          message: "content.attachment.download".tr(namedArgs: {"filename": widget.attachment.filename}),
                          child: IconButton(
                            icon: Icon(Mdi.download), 
                            onPressed: () => launch(API.get.urlScheme+Config.server
                              +(widget.attachment.downloadUrl ?? widget.attachment.url.replaceFirst("/view/", "/download/"))),
                          ),
                        ),
                      ),
                    ),
                    if (widget.attachment.yours) Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(24)),
                        child: Tooltip(
                          message: "content.attachment.remove".tr(),
                          child: IconButton(
                            icon: Icon(Mdi.deleteOutline), 
                            onPressed: null,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ),
        ],
      ),
    );
  }
}

class EmbeddedImageAttachmentPreview extends StatelessWidget {
  final ContentAttachment attachment;
  const EmbeddedImageAttachmentPreview({ Key? key, required this.attachment }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              //color: context.theme().colorScheme.primaryVariant
            ),
            child: Image.network(
              API.get.urlScheme+Config.server+attachment.url,
              fit: BoxFit.contain, //experiment with this, maybe
              errorBuilder: (context, error, st) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Mdi.imageBroken, color: Colors.orange),
                ),
              )
            )
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(attachment.filename, 
              style: context.textTheme().headline5, 
              maxLines: 2, 
              overflow: TextOverflow.ellipsis
            ),
          ),
        )
      ],
    );
  }
}