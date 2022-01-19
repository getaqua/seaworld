import 'package:easy_localization/src/public_ext.dart';
import "package:flutter/material.dart";
import 'package:go_router/go_router.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/api/main.dart';
import 'package:seaworld/helpers/config.dart';
import 'package:seaworld/helpers/extensions.dart';
import 'package:seaworld/models/flow.dart';
import 'package:seaworld/widgets/pfp.dart';

class FlowPreviewPopupMenu {
  static const Offset center = Offset(36, 36);
  OverlayEntry? _overlayEntry;

  show({required BuildContext context, required PartialFlow flow, Rect? position}) {
    final _position = (context.findRenderObject() as RenderBox?)?.localToGlobal(center);
    final pos = position?.topLeft ?? _position;
    _overlayEntry ??= OverlayEntry(builder: (context) => Stack(
      children: [
        Positioned.fill(child: GestureDetector(onTapDown: (_) => _overlayEntry?.remove())),
        Positioned(top: pos!.dy, left: pos.dx, child: Material(
          child: _FlowPreviewPopupMenu(flow: flow),
          elevation: 2,
          borderRadius: BorderRadius.all(Radius.circular(8.0))
        ))
      ]
    ));
    Overlay.of(context)?.insert(_overlayEntry!);
  }
}

class _FlowPreviewPopupMenu extends StatefulWidget {
  final PartialFlow flow;

  @override
  _FlowPreviewPopupMenuState createState() => _FlowPreviewPopupMenuState();

  const _FlowPreviewPopupMenu({
    Key? key,
    required this.flow
  }) : super(key: key);
}

class _FlowPreviewPopupMenuState extends State<_FlowPreviewPopupMenu> {
  @override
  Widget build(BuildContext context) {
    final hasBanner = widget.flow.bannerUrl != null;
    return Container(
      width: 320,
      //height: 480,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.all(Radius.circular(8.0))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasBanner) Container(
            height: 192,
            decoration: BoxDecoration(
              color: context.theme().colorScheme.primary,
              borderRadius: BorderRadius.circular(8)
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.zero),
                      image: DecorationImage(
                        image: NetworkImage(API.get.urlScheme+Config.server+widget.flow.bannerUrl!),
                        fit: BoxFit.cover
                      )
                    ),
                  ),
                  height: 96,
                  left: 0,
                  right: 0,
                  top: 0,
                ),
                Positioned(
                  top: 56,
                  width: 80,
                  child: Container(
                    height: 80,
                    width: 80,
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.theme().colorScheme.primary,
                      borderRadius: BorderRadius.circular(64)
                    ),
                    alignment: Alignment.centerLeft,
                    child: Tooltip(
                      message: "flow.open".tr(namedArgs: {"id": widget.flow.id}),
                      child: InkResponse(
                        onTap: () async {
                          Navigator.pop(context);
                          context.go("/flow/"+widget.flow.snowflake);
                        },
                        child: ProfilePicture(
                          child: widget.flow.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+widget.flow.avatarUrl!) : null,
                          size: 72, notchSize: 24,
                          fallbackChild: FallbackProfilePicture(flow: widget.flow)
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 136,
                  child: Text(widget.flow.name, style: context.textTheme().headline6?.copyWith(color: Colors.black))
                ),
                Positioned(
                  top: 164,
                  child: Text(widget.flow.id, style: context.textTheme().bodyText2?.copyWith(color: Colors.black))
                )
              ],
            ),
          )
          else Container(
            height: 96,
            decoration: BoxDecoration(
              color: context.theme().colorScheme.primary,
              borderRadius: BorderRadius.circular(8)
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ProfilePicture(
                    child: widget.flow.avatarUrl != null ? NetworkImage(API.get.urlScheme+Config.server+widget.flow.avatarUrl!) : null,
                    size: 72, notchSize: 24,
                    fallbackChild: FallbackProfilePicture(flow: widget.flow)
                  ),
                ),
                Expanded(child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.flow.name, 
                        style: context.textTheme().headline6?.copyWith(color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.fade
                      ),
                      Text(widget.flow.id,
                        style: context.textTheme().bodyText2?.copyWith(color: Colors.black),
                        maxLines: 1,
                        overflow: TextOverflow.fade
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          //Text("TEST")
          if (widget.flow.description?.isNotEmpty == true) Padding(
            child: Text(widget.flow.description!),
            padding: EdgeInsets.all(8),
          )
        ],
      )
    );
  }
}

class _FlowPreviewAnimation extends StatefulWidget {
  final Widget child;

  const _FlowPreviewAnimation({
    Key? key,
    required this.child
  }) : super(key: key);

  @override
  __FlowPreviewAnimationState createState() => __FlowPreviewAnimationState();
}

class __FlowPreviewAnimationState extends State<_FlowPreviewAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _position;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, 
      duration: Duration(milliseconds: 250),
    );
    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
    _position = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.1, 0.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _position,
        child: widget.child,
      )
    );
  }
}