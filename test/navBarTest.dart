import 'dart:async';

import 'package:final_project_2023/Widgets/nav_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:final_project_2023/Pages/view_user_profile.dart'; // Your path might be different

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {
  @override
  String get uid => 'test_uid';
}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {
  final Stream<DocumentSnapshot<Map<String, dynamic>>> stream;

  MockDocumentReference(this.stream);

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> snapshots({bool includeMetadataChanges = false}) => stream;
}

class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {
  final DocumentReference<Map<String, dynamic>> documentReference;

  MockCollectionReference(this.documentReference);

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) => documentReference;
}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {
  final CollectionReference<Map<String, dynamic>> collectionReference;

  MockFirebaseFirestore(this.collectionReference);

  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return collectionReference;
  }
}


// Annotation for Mockito to generate the Mock classes
@GenerateMocks([], customMocks: [
  MockSpec<FirebaseAuth>(as: #MockFirebaseAuth),
  MockSpec<FirebaseFirestore>(as: #MockFirebaseFirestore),
  MockSpec<User>(as: #MockUser),
  MockSpec<DocumentSnapshot>(as: #MockDocumentSnapshot),
  MockSpec<CollectionReference>(as: #MockCollectionReference),
  MockSpec<DocumentReference>(as: #MockDocumentReference),
])

void main() {
  MockFirebaseAuth mockFirebaseAuth;
  MockFirebaseFirestore mockFirebaseFirestore;
  MockUser mockUser;
  MockDocumentSnapshot mockDocumentSnapshot;
  CollectionReference<Map<String, dynamic>> collectionReference;
  DocumentReference<Map<String, dynamic>> documentReference;

  setUp(() {
    mockUser = MockUser();
    mockDocumentSnapshot = MockDocumentSnapshot();
    documentReference = MockDocumentReference(Stream.fromIterable([mockDocumentSnapshot]));
    collectionReference = MockCollectionReference(documentReference);
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseFirestore = MockFirebaseFirestore(collectionReference);

    when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(mockDocumentSnapshot.data()).thenReturn({
      'username': 'Test User',
      'email': 'test.user@example.com',
      'score': 100,
      'URL': 'https://example.com',
      'UID': 'test_uid',
    });
  });

  testWidgets('Display the correct username', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MaterialApp(
      home: NavBar({'username': 'Test User', 'email': 'test.user@example.com', 'score': 100}, StreamController<List<double>>()),
    ));

    // Check if the username is displayed correctly.
    expect(find.text('Test User'), findsOneWidget);
  });
}
