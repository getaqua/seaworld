import 'package:easy_localization/easy_localization.dart';
import "package:flutter/material.dart";
import 'package:mdi/mdi.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/models/content.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageLargeView extends StatefulWidget {
  final ContentAttachment attachment;
  const ImageLargeView({ Key? key, required this.attachment }) : super(key: key);

  @override
  _ImageLargeViewState createState() => _ImageLargeViewState();
}

class _ImageLargeViewState extends State<ImageLargeView> {
  bool _showFullscreen = false;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(child: Container(color: Colors.black87)),
        Positioned.fill(child: GestureDetector(
          onTap: () => setState(() => _showFullscreen = !_showFullscreen),
          child: InteractiveViewer(
            child: Image.network(API.get.urlScheme+Config.server+widget.attachment.url),
          ),
        )),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: AppBar.preferredHeightFor(context, Size.fromHeight(56)),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            transform: _showFullscreen ? Matrix4.translation(Vector3(0, -72, 0)) : Matrix4.translation(Vector3(0, 0, 0)),
            child: AppBar(
              primary: true,
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: Colors.black45,
              title: Text(widget.attachment.filename),
              actions: [
                Tooltip(
                  message: "content.attachment.download_generic".tr(),
                  child: IconButton(
                    onPressed: () => launch(API.get.urlScheme+Config.server
                      +(widget.attachment.downloadUrl ?? widget.attachment.url.replaceFirst("/view/", "/download/"))),
                    icon: Icon(Mdi.download)
                  ),
                ),
                Tooltip(
                  message: "content.attachment.open".tr(),
                  child: IconButton(
                    onPressed: () => launch(API.get.urlScheme+Config.server+widget.attachment.url),
                    icon: Icon(Mdi.openInApp)
                  ),
                )
              ],
            ),
          )
        ),
      ],
    );
  }
}