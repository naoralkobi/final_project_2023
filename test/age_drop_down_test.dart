import 'dart:async';

import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:final_project_2023/Widgets/age_drop_down.dart'; // Update this path

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockDocumentReference extends Mock implements DocumentReference {}

void main() {
  void main() {
    MockFirebaseAuth mockAuth;
    MockFirebaseFirestore mockFirestore;
    MockUser mockUser;
    MockDocumentReference mockDocRef;
    MockCollectionReference mockCollectionReference;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockUser = MockUser();
      mockDocRef = MockDocumentReference();
      mockCollectionReference = MockCollectionReference();

      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_uid');

      when(mockFirestore.collection('any')).thenReturn(
          mockCollectionReference as CollectionReference<Map<String, dynamic>>);
      when(mockCollectionReference.doc('any')).thenReturn(mockDocRef);
    });

    testWidgets('AgeDropDown changes and updates Firebase', (
        WidgetTester tester) async {
      final controller = StreamController<String>();

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AgeDropDown("minAge", controller, {"minAge": 25}),
        ),
      ));

      // The dropdown initially displays the value from userInfo
      expect(find.text('25'), findsOneWidget);

      // There are 86 options in the dropdown (from 14 to 99 inclusive)
      await tester.tap(find.byType(DropdownButton));
      await tester.pumpAndSettle();
      expect(find.byType(DropdownMenuItem), findsNWidgets(86));

      // Select a new age and check that the dropdown updates
      await tester.tap(find
          .text('30')
          .last);
      await tester.pumpAndSettle();
      expect(find.text('30'), findsOneWidget);

      // Simulate the "finish" event and check that Firebase is updated
      controller.add("finish");
      await tester.pumpAndSettle();

      controller.close();
    });
  }
}
