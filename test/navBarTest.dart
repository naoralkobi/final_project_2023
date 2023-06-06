// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:final_project_2023/Widgets/navBar.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:mockito/mockito.dart';
// import 'package:provider/provider.dart';
//
// import '../lib/FireBase/auth_repository.dart';
//
// // Mock classes
// class MockFirebaseFirestore extends Mock implements FirebaseFirestore {
//   MockCollectionReference? collectionReference;
//
//   MockFirebaseFirestore() {
//     collectionReference = MockCollectionReference();
//   }
//
//   @override
//   CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
//     return collectionReference as CollectionReference<Map<String, dynamic>>;
//   }
// }
//
// class MockAuthRepository extends Mock implements AuthRepository {}
// class MockUser extends Mock implements User {}
// class MockCollectionReference extends Mock implements CollectionReference {}
// class MockDocumentReference extends Mock implements DocumentReference {}
// class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}
// class MockStreamController extends Mock implements StreamController<List<double>> {}
//
//
// void main() {
//
//   MockFirebaseFirestore mockFirebaseFirestore = MockFirebaseFirestore();
//   MockCollectionReference mockCollectionReference = MockCollectionReference();
//   MockDocumentReference mockDocumentReference = MockDocumentReference();
//   MockDocumentSnapshot mockDocumentSnapshot = MockDocumentSnapshot();
//   MockStreamController mockStreamController = MockStreamController();
//
//   // setUpAll(() async {
//   //   await Firebase.initializeApp();
//   // });
//
//   setUp(() {
//     when(mockFirebaseFirestore.collection('users')).thenReturn(mockCollectionReference as CollectionReference<Map<String, dynamic>>);
//     when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
//     when(mockDocumentReference.snapshots()).thenAnswer((_) {
//       return Stream<DocumentSnapshot>.fromIterable([mockDocumentSnapshot]);
//     });
//     when(mockDocumentSnapshot.data()).thenReturn({
//       'username': 'Test User',
//       'email': 'testuser@test.com',
//       'URL': 'https://example.com/avatar.png',
//       'UID': 'testUID',
//       'score': 100,
//     });
//   });
//
//   testWidgets('NavBar UI Test', (WidgetTester tester) async {
//     await tester.pumpWidget(
//       MultiProvider(
//         providers: [
//           Provider<FirebaseFirestore>.value(value: mockFirebaseFirestore),
//           Provider<AuthRepository>.value(value: MockAuthRepository()),
//         ],
//         child: MaterialApp(
//           home: NavBar({}, mockStreamController),
//         ),
//       ),
//     );
//
//     await tester.pumpAndSettle();
//
//     // Verifying if the avatar image, username, and email are being displayed
//     expect(find.text('Test User'), findsOneWidget);
//     expect(find.text('testuser@test.com'), findsOneWidget);
//     expect(find.byType(CircleAvatar), findsOneWidget);
//
//     // Verifying if all the items are present in the drawer
//     expect(find.text('Friends'), findsOneWidget);
//     expect(find.text('Leaderboard'), findsOneWidget);
//     expect(find.text('Learn to speak'), findsOneWidget);
//     expect(find.text('Learn with videos'), findsOneWidget);
//     expect(find.text('Translate'), findsOneWidget);
//     expect(find.text('About'), findsOneWidget);
//     expect(find.text('Logout'), findsOneWidget);
//
//     // Verifying if the user's score is being displayed
//     expect(find.text('100'), findsOneWidget);
//   });
// }
import 'dart:async';

import 'package:final_project_2023/Widgets/navBar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:final_project_2023/Widgets/navBar.dart'; // Your path might be different
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
