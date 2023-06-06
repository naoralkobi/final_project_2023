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

      double result = calculateAccuracyScore(recognizedText,recognizedText);

      // The recognized text matches the expected text exactly, so we expect the score to be 1.
      expect(result, 1.0);
    });

    test('Text to Phonemes test', () async {
      String text = 'hello world';
      String language = 'English';

      String result = await textToPhonemes(text, language);

      // Here, you should replace 'expectedResult' with the phonemes string that you expect
      // the text "hello world" to be converted into.
      String expectedResult = 'h\u0259l\u02c8\u0259\u028a w\u02c8\u025c\u02d0ld';

      expect(result, expectedResult);
    });


    test('Levenshtein Distance test', () async {
      String originalText = 'hello world';
      String recognizedText = 'hellu world';
      String language = 'English';

      double result = await calculatePronunciationScore(originalText, recognizedText, language);

      // The expected distance could be computed separately (in this case, it's 5)
      double expectedDistance = 0.6153846153846154;

      expect(result, expectedDistance);
    });

    test('Feedback generation test', () {
      double overallScore = 0.65;

      String result = generateFeedback(overallScore);

      // Given an overall score of 0.65, we expect the feedback to encourage improvement in accuracy and pronunciation.
      expect(result, 'Good effort! Focus on improving accuracy and pronunciation.');
    });
  });
}
