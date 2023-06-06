/// not working!

// import 'package:flutter_test/flutter_test.dart';
// import 'package:flutter/material.dart';
// import 'package:final_project_2023/Widgets/ChooseLanguage.dart';
// import 'package:mockito/mockito.dart';
// import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
//
// class MockAuthRepository extends Mock {
//   String uid = "123";
// }
//
// void main() {
//   testWidgets('ChooseLanguage widget test', (WidgetTester tester) async {
//     // Create a MockFirestoreInstance for testing
//     // final instance = FakeFirebaseFirestore();
//     //
//     // // Add a user document in the 'users' collection
//     // await instance.collection('users').doc('123').set({
//     //   'Languages': {'English': 'Beginner', 'French': 'Beginner'}
//     // });
//
//     // Create the widget by telling the tester to build it.
//     await tester.pumpWidget(MaterialApp(
//       home: Scaffold(
//         body: ChooseLanguage(false, {}, isFromFriendList: true),
//       ),
//     ));
//
//     // Create the Finders.
//     final dialogFinder = find.byType(Dialog);
//
//     // Use the `pumpAndSettle` function in order to allow async work to complete.
//     await tester.pumpAndSettle();
//
//     // Verify that the Dialog is present.
//     expect(dialogFinder, findsOneWidget);
//   });
// }
