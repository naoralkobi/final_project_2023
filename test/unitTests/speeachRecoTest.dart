import 'package:flutter_test/flutter_test.dart';
import 'package:final_project_2023/Pages/speech_recognition.dart';



void main() {
  // Create an instance of the widget for testing.
  // You may need to pass some initial parameters if they are required.

  group('Speech Evaluation Widget Test', () {
    test('Hamming distance test', () {
      String recognizedText = 'hello';
      String randomWord = 'hells';

      double result = calculateHammingDistance(recognizedText, randomWord);

      // We expect the result to be 0.8 because there is only one character difference.
      expect(result, 0.8);
    });

    test('Accuracy score test', () {
      String recognizedText = 'Hello, how are you today?';

      double result = calculateAccuracyScore(recognizedText);

      // The recognized text matches the expected text exactly, so we expect the score to be 1.
      expect(result, 1.0);
    });

    test('Feedback generation test', () {
      double overallScore = 0.65;

      String result = generateFeedback(overallScore);

      // Given an overall score of 0.65, we expect the feedback to encourage improvement in accuracy and pronunciation.
      expect(result, 'Good effort! Focus on improving accuracy and pronunciation.');
    });
  });
}
