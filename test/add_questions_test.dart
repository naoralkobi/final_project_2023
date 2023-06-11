import 'package:final_project_2023/screen_size_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:final_project_2023/Pages/add_question.dart';
import 'package:mockito/mockito.dart';

class MockBuildContext extends Mock implements BuildContext {
  @override
  Size get size => Size(1080, 1920);  // Provide a size here.
}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  final mockObserver = MockNavigatorObserver();

  testWidgets('SizeConfig initialization', (WidgetTester tester) async {
    // create a new instance of SizeConfig
    SizeConfig sizeConfig = SizeConfig();

    // pump the widget
    await tester.pumpWidget(
      Builder(builder: (BuildContext context) {
        // initialize the SizeConfig
        sizeConfig.init(context);
        return Container();
      }),
    );
  });

  testWidgets('AddQuestion page test', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AddQuestion(),
      navigatorObservers: [mockObserver],
    ));

    final languageDropdown = find.byKey(ValueKey('languageDropdown'));
    final levelDropdown = find.byKey(ValueKey('levelDropdown'));
    final translateTheWordButton = find.text('Translate the word');
    final whatsInThePictureButton = find.text('What’s in the picture');
    final completeTheSentenceButton = find.text('Complete the sentence');
    final verbConjugationButton = find.text('Verb conjugation');


    // Verify that the initial state of the widget tree is as expected.
    expect(languageDropdown, findsOneWidget);
    expect(levelDropdown, findsOneWidget);
    expect(translateTheWordButton, findsOneWidget);
    expect(whatsInThePictureButton, findsOneWidget);
    expect(completeTheSentenceButton, findsOneWidget);
    expect(verbConjugationButton, findsOneWidget);

    // Tap on the buttons without selecting language and level
    await tester.tap(translateTheWordButton);
    await tester.pumpAndSettle();

    // Verify that the appropriate error message is shown
    expect(find.text('You must select a language'), findsOneWidget);

    await tester.tap(whatsInThePictureButton);
    await tester.pumpAndSettle();

    // Verify that the appropriate error message is shown
    expect(find.text('You must select a language'), findsOneWidget);

    await tester.tap(completeTheSentenceButton);
    await tester.pumpAndSettle();

    // Verify that the appropriate error message is shown
    expect(find.text('You must select a language'), findsOneWidget);

    await tester.tap(verbConjugationButton);
    await tester.pumpAndSettle();

    // Verify that the appropriate error message is shown
    expect(find.text('You must select a language'), findsOneWidget);

  });
}
