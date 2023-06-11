import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project_2023/Widgets/calling_dialog.dart';

void main() {
  testWidgets('CallingDialog displays and behaves correctly', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (BuildContext context) {
            // Use Future to ensure dialog is opened after the scaffold finishes building
            Future.microtask(() => showDialog(
              context: context,
              builder: (_) => CallingDialog(),
              barrierDismissible: false,
            ));
            return Container();
          },
        ),
      ),
    ));

    // Let microtask queue clear
    await tester.pump();

// The dialog is opened, let's pump it for the duration of the first periodic event
    await tester.pump(Duration(seconds: 1));

// Now let's find the widgets
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Calling'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

// Pump for 1 second and expect an additional dot in the "Calling" text
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Calling.'), findsOneWidget);

// Pump for another second and expect one more dot in the "Calling" text
    await tester.pump(Duration(seconds: 1));
    expect(find.text('Calling..'), findsOneWidget);

    // Tap the close icon and expect the dialog to be closed
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });
}
