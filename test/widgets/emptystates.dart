import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seaworld/widgets/empty.dart';

void main() {
  group('Empty state', () {
    /// This test just makes sure the widget renders. No foul play here
    testWidgets('no content', (tester) async {
      tester.pumpWidget(GetMaterialApp(home: Center(child: NormalEmptyState())));
    });
  });
}