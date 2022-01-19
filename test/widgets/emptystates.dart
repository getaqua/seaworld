import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:seaworld/widgets/empty.dart';

void main() {
  group('Empty state', () {
    /// This test just makes sure the widget renders. No foul play here
    testWidgets('no content', (tester) async {
      tester.pumpWidget(MaterialApp(home: Center(child: NormalEmptyState())));
    });
  });
}