import 'package:easy_localization/src/public_ext.dart';
import "package:flutter/material.dart";
import 'package:seaworld/views/crash.dart';

enum Corner {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  // uses directionality
  topStart,
  topEnd,
  bottomStart,
  bottomEnd
}
Corner normalizeCorner(BuildContext context, Corner corner) {
  if (corner == Corner.topLeft || corner == Corner.topRight
  || corner == Corner.bottomLeft || corner == Corner.bottomRight) return corner;

  final directionality = Directionality.maybeOf(context);
  
  if ((directionality == TextDirection.ltr || directionality == null)
  && (corner == Corner.topStart || corner == Corner.bottomStart)) {
    return corner == Corner.topStart ? Corner.topLeft : Corner.bottomLeft;
  } else if (directionality == TextDirection.ltr
  && (corner == Corner.topEnd || corner == Corner.bottomEnd)) {
    return corner == Corner.topStart ? Corner.topRight : Corner.bottomRight;
  }

  if (directionality == TextDirection.rtl
  && (corner == Corner.topStart || corner == Corner.bottomStart)) {
    return corner == Corner.topStart ? Corner.topRight : Corner.bottomRight;
  } else if (directionality == TextDirection.ltr
  && (corner == Corner.topEnd || corner == Corner.bottomEnd)) {
    return corner == Corner.topStart ? Corner.topLeft : Corner.bottomLeft;
  }
  // this should NEVER run!
  return Corner.topLeft;
}

class InAppNotification extends StatelessWidget {
  late final OverlayEntry _overlay;
  /// The in-app notification's title.
  final Text? title;
  /// The in-app notification's text.
  final Text? text;
  /// An image to show as an icon next to the title.
  /// Is mutually exclusive with [icon].
  final ImageProvider? iconImage;
  /// An icon to show next to the title.
  /// Is mutually exclusive with [iconImage].
  final Icon? icon;
  /// An image to display next to the notification.
  /// Will be cropped to a square and set to fit.
  final ImageProvider? image;
  /// Which corner the overlay is to display on.
  final Corner corner;
  // ignore: prefer_const_constructors_in_immutables
  InAppNotification({
    Key? key,
    this.title,
    this.text,
    this.iconImage,
    this.icon,
    this.image,
    this.corner = Corner.topStart
  }) 
  : assert(iconImage == null || icon == null, "iconImage and icon cannot both be set"),
    super(key: key);

  @override
  Widget build(BuildContext context) {
    final corner = normalizeCorner(context, this.corner);
    final _alignRight = corner == Corner.topRight || corner == Corner.bottomRight;
    final _alignEnd = this.corner == Corner.topRight || this.corner == Corner.bottomRight
    || this.corner == Corner.topEnd || this.corner == Corner.topStart;
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (_) => _overlay.remove(),
      child: Container(
        width: 360,
        padding: EdgeInsets.all(8.0),
        child: Card(
          child: Column(
            children: [
              Row(
                children: [
                  if (iconImage != null) Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Image(image: iconImage!, width: 24, height: 24),
                  )
                  else if (icon != null) Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: icon!,
                  ),
                  if (title != null) Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DefaultTextStyle(style: Theme.of(context).textTheme.subtitle1!, child: title!),
                  ),
                  Expanded(child: Container()),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SizedBox(
                      child: IconButton(onPressed: () => _overlay.remove(), icon: Icon(Icons.close), padding: EdgeInsets.zero),
                      width: 24,
                      height: 24
                    ),
                  )
                ],
                mainAxisAlignment: _alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min
              ),
              if (text != null) Padding(
                padding: const EdgeInsets.all(8.0),
                child: text!,
              ),
            ],
            mainAxisAlignment: _alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
          ),
        ),
      ),
    );
  }

  static OverlayEntry showOverlayIn(BuildContext context, InAppNotification widget) {
    final overlay = OverlayEntry(builder: (context) {
      if (widget.corner == Corner.topLeft) {
        return Positioned(top: 0, left: 0, child: widget);
      } else if (widget.corner == Corner.topRight) {
        return Positioned(top: 0, right: 0, child: widget);
      } else if (widget.corner == Corner.bottomLeft) {
        return Positioned(bottom: 0, left: 0, child: widget);
      } else if (widget.corner == Corner.bottomRight) {
        return Positioned(bottom: 0, right: 0, child: widget);
      } else {
        final dir = Directionality.maybeOf(context) ?? TextDirection.ltr;
        if (widget.corner == Corner.topStart) {
          return Positioned.directional(textDirection: dir, top: 0, start: 0, child: widget);
        } else if (widget.corner == Corner.topEnd) {
          return Positioned.directional(textDirection: dir, top: 0, end: 0, child: widget);
        } else if (widget.corner == Corner.bottomStart) {
          return Positioned.directional(textDirection: dir, bottom: 0, start: 0, child: widget);
        } else if (widget.corner == Corner.bottomEnd) {
          return Positioned.directional(textDirection: dir, bottom: 0, end: 0, child: widget);
        } else {
          return CrashedView(helptext: "crash.inappnotify.generic".tr());
        }
      }
    });
    Overlay.of(context)!.insert(overlay);
    widget._overlay = overlay;
    return overlay;
  }
}