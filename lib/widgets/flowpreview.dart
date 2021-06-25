import "package:flutter/material.dart";
import 'package:get/get.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/models/flow.dart';

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

  _FlowPreviewPopupMenu({
    Key? key,
    required this.flow
  }) : super(key: key);
}

class _FlowPreviewPopupMenuState extends State<_FlowPreviewPopupMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      //height: 480,
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.primaryVariant,
        borderRadius: BorderRadius.all(Radius.circular(8.0))
      ),
      child: Column(
        children: [
          Container(
            height: 192,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8)
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  child: Material(
                    color: Colors.green.shade900,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8), bottom: Radius.zero)
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
                      color: Get.theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(64)
                    ),
                    alignment: Alignment.centerLeft,
                    child: Material(
                      borderRadius: BorderRadius.circular(64),
                      color: Get.theme.colorScheme.surface,
                      child: Stack(children: [
                        // if (_viewProfilePrompt) ...[
                        //   Center(child: Icon(Mdi.account, color: Colors.white)),
                        //   Material(color: Colors.black54)
                        // ],
                        Center(child: Text("X", style: Get.textTheme.headline6)),
                      ]),
                    ),
                  ),
                ),
                Positioned(
                  top: 136,
                  child: Text(widget.flow.name, style: Get.textTheme.headline6)
                ),
                Positioned(
                  top: 164,
                  child: Text(widget.flow.id, style: Get.textTheme.bodyText2)
                )
              ],
            ),
          ),
          Text("TEST")
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