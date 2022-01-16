import 'package:flutter/material.dart';
import 'package:seaworld/models/flow.dart';

class ProfilePicture extends StatelessWidget {
  /// The width and height of the image.
  final double size;
  /// The diameter of the punch-hole.
  final double notchSize;
  /// The child of the punch-hole. 
  /// If left `null`, the notch is skipped.
  final Widget? notchChild;
  /// The image. If it is left `null`, 
  /// the [fallbackChild] will display instead.
  final ImageProvider? child;
  /// A fallback profile picture, typically the
  /// first letter of the user's ID or their
  /// (first two or three) initials from their
  /// display name.
  final Widget fallbackChild;
  /// A background color to display behind the
  /// profile picture. Transparent by default.
  final Color background;

  const ProfilePicture({
    Key? key,
    this.size = 56,
    this.notchSize = 24,
    this.notchChild,
    this.child,
    required this.fallbackChild,
    this.background = Colors.transparent
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: Material(
              borderRadius: BorderRadius.circular(size/2),
              color: background,
            ),
          ),
          child != null ? ClipOval(
            child: notchChild != null ? ClipPath(
              clipper: NotchedCircleClipper(notchSize: notchSize),
              child: Image(
                image: child!,
                fit: BoxFit.cover,
                errorBuilder: (context, _, __) => fallbackChild
              )
            ) : Image(
              image: child!,
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) => fallbackChild
            )
          ) : ClipOval(
            child: notchChild != null ? ClipPath(
              clipper: NotchedCircleClipper(notchSize: notchSize),
              child: fallbackChild
            ) : fallbackChild
          ),
          if (notchChild != null) Positioned(
            top: size-notchSize,
            left: size-notchSize,
            height: notchSize,
            width: notchSize,
            child: Center(
              child: notchChild
            )
          )
        ]
      )
    );
  }
}

class NotchedCircleClipper extends CustomClipper<Path> {
  final double notchSize;

  NotchedCircleClipper({
    Listenable? reclip,
    this.notchSize = 24
  }): super(reclip: reclip);

  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size.width-(notchSize/2), size.height-(notchSize/2)),
          radius: notchSize/2))
      ..addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class FallbackProfilePicture extends StatelessWidget {
  final PartialFlow? flow;
  const FallbackProfilePicture({Key? key, this.flow}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _idModulo = BigInt.parse(flow?.snowflake ?? "0", radix: 16) % BigInt.from(6);
    return DecoratedBox(
      child: Center(child: Text(
        (flow?.name ?? "Unknown User").splitMapJoin(" ",
          onMatch: (_)=>"",
          onNonMatch: (v)=>v.characters.first
        ),
        style: Theme.of(context).textTheme.headline6?.copyWith(color: Colors.black),
      )),
      decoration: BoxDecoration(
        color: _idModulo == BigInt.from(0) ? Colors.red
        : _idModulo == BigInt.from(1) ? Colors.orange
        : _idModulo == BigInt.from(2) ? Colors.yellow
        : _idModulo == BigInt.from(3) ? Colors.green
        : _idModulo == BigInt.from(4) ? Colors.blue
        : _idModulo == BigInt.from(5) ? Colors.indigo
        : _idModulo == BigInt.from(6) ? Colors.purple
        : Colors.white // if I misunderstood how modulo works
      ),
    );
  }

}