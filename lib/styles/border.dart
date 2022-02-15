import "package:flutter/material.dart";

class ButtonBorder extends MaterialStateProperty<BorderSide> {
  final Color color;
  ButtonBorder(this.color);

  @override
  BorderSide resolve(Set<MaterialState> states) {
    return BorderSide(
      color: states.contains(MaterialState.disabled) ? color.withOpacity(.38) : color,
      width: 1,
    );
  }
}

class StatedColor extends MaterialStateColor {
  final Color color;
  StatedColor(this.color) : super(0);

  @override
  Color resolve(Set<MaterialState> states) {
    return states.contains(MaterialState.disabled) ? color.withOpacity(.38) : color;
  }
}