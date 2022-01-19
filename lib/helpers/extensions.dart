import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  ThemeData theme() => Theme.of(this);
  TextTheme textTheme() => Theme.of(this).textTheme;
}