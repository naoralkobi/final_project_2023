import 'dart:async';

import 'package:final_project_2023/Widgets/language_widget.dart';
import 'package:final_project_2023/consts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/profile_vars.dart';
import 'package:final_project_2023/consts.dart';

void main() {
  testWidgets('LanguageWidget UI Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: LanguageWidget("English", StreamController(), {LANGUAGES: {'English': ADVANCED}}),
    ));

    // Verify the presence of CheckboxListTile.
    expect(find.byType(CheckboxListTile), findsOneWidget);

    // Verify the presence of DropdownButton if the checkbox is checked.
    expect(find.byType(DropdownButton), findsOneWidget);

    // Tap the checkbox.
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();

    // Verify the checkbox change.
    CheckboxListTile checkbox = tester.widget(find.byType(CheckboxListTile));
    expect(checkbox.value, false);

    // The DropdownButton should disappear after the checkbox is unchecked.
    expect(find.byType(DropdownButton), findsNothing);
  });
}
