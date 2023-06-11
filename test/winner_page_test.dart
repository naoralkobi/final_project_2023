import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter/material.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:final_project_2023/Pages/winner_page.dart';
import 'package:firebase_core/firebase_core.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('WinnerPage Widget Test', (WidgetTester tester) async {
    // Mock the Firestore instance
    final mockFirestore = FakeFirebaseFirestore();

    String gameId = 'gameId_123';
    Map userInfo = {'UID': 'user_1', 'URL': 'http://imageurl.com/image1.jpg', 'USERNAME': 'User1'};
    Map opponentInfo = {'UID': 'user_2', 'URL': 'http://imageurl.com/image2.jpg', 'USERNAME': 'User2'};

    // Mock the data
    await mockFirestore.collection('games').doc(gameId).set({
      'uid1': userInfo['UID'],
      'questions': [
        {
          'user1Answer': 'answer1',
          'user2Answer': 'answer1',
          'correctAnswer': 'answer1',
        }
      ],
    });

    // Build the WinnerPage widget
    await tester.pumpWidget(
      MaterialApp(
        home: WinnerPage(gameId, userInfo, opponentInfo),
        navigatorObservers: [MockNavigatorObserver()],
      ),
    );

    // Verify if WinnerPage is rendered without any errors
    expect(find.byType(WinnerPage), findsOneWidget);
  });
}
