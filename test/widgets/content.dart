import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hive_test/hive_test.dart';
import 'package:mdi/mdi.dart';
import 'package:seaworld/models/content.dart';
import 'package:seaworld/widgets/content.dart';

/// This test is NOT localized.
/// Use the translation keys to find widgets
/// based on their labels (i.e. `"content.delete"`).

void main() {
  group('Content widgets', () {
    setUp(() async {
      await setUpTestHive();
      await Hive.openBox("config");
    });
    testWidgets('Basic text-only render test', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: ContentWidget(Content.fromJSON({
            "author": {
              "name": "Mock User 1",
              "id": "//mock_user1"
            },
            "text": "This is a test of ContentWidget.",
            "snowflake": "A00027BF9388AA000000",
            "inFlowId": "//mock_user1",
            "timestamp": "2021-08-21T19:29:26.312Z"
          })),
        ),
      ));
      tester.widget(find.text("Mock User 1")); // The username box.
      tester.widget(find.text("This is a test of ContentWidget.")); // The text field.
      tester.widget(find.widgetWithIcon(IconButton, Mdi.textBox)); // The "Read more" button.
      await tester.tap(find.byIcon(Icons.more_vert)); // Tap the "more" icon button.
      await tester.pumpAndSettle();
      expect(find.text("content.delete"), findsNothing, reason: "Delete button should not exist: it is not your post!");
    });
    testWidgets('Embedded text-only render test', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: ContentWidget(Content.fromJSON({
            "author": {
              "name": "Mock User 1",
              "id": "//mock_user1"
            },
            "text": "This is a test of ContentWidget.",
            "snowflake": "A00027BF9388AA000000",
            "inFlowId": "//mock_user1",
            "timestamp": "2021-08-21T19:29:26.312Z"
          }), embedded: true),
        ),
      ));
      //expect(tester.widgetList(find.widgetWithIcon(IconButton, Mdi.textBox)).isEmpty, true, reason: "There should not be a \"read more\" button in an embedded post.");
      expect(find.widgetWithIcon(IconButton, Mdi.textBox), findsNothing, reason: "There should not be a \"read more\" button in an embedded post.");
      //expect(tester.widgetList().isEmpty, true, reason: "\"More options\" button should not exist in an embedded post.");
      expect(find.byIcon(Icons.more_vert), findsNothing, reason: "\"More options\" button should not exist in an embedded post.");
    });
    testWidgets('Owned text-only render test', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Center(
          child: ContentWidget(Content.fromJSON({
            "author": {
              "name": "Example User",
              "id": "//exampleuser"
            },
            "text": "This is a test of ContentWidget.",
            "snowflake": "A00027C0FBAF72400000",
            "inFlowId": "//exampleuser",
            "timestamp": "2021-08-22T21:42:57.865Z"
          }))
        )
      ));
      expect(find.text("Example User"), findsOneWidget);
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      expect(find.text("content.delete"), findsOneWidget, reason: "Delete button not found when Content belongs to the user");
    });
    tearDown(() async {
      await tearDownTestHive();
    });
  });
}