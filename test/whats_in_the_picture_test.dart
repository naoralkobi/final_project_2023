import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:final_project_2023/Pages/whats_in_the_picture.dart'; // replace with the path to your widget's dart file

class FirebaseAppMock extends Mock implements FirebaseApp {}

void main() {
  group('YourWidget', () {
    setUp(() async {
      // Mock the Firebase app
      FirebaseApp app = FirebaseAppMock();
      //FirebaseFirestore.instance = MockFirestoreInstance();
    });

    testWidgets('displays validation messages when fields are empty', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(MaterialApp(home: WhatsInThePicture('Arabic','Beginner','Beginner')));

      final button = find.text('Finish');
      await tester.tap(button);

      await tester.pump();

      expect(find.text('Fill in all fields'), findsOneWidget);
      expect(find.text('Upload an Image'), findsOneWidget);
    });

    // Add more tests as per your application's features
  });
}
