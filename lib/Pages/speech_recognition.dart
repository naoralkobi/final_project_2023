import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart' show PlatformException;

class SpeechRecognitionScreen extends StatefulWidget {
  @override
  _SpeechRecognitionScreenState createState() =>
      _SpeechRecognitionScreenState();
}

class _SpeechRecognitionScreenState extends State<SpeechRecognitionScreen> {
  stt.SpeechToText? _speech;
  String _recognizedText = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _speech!.errorListener = (error) {
      print('Speech recognition error: ${error.errorMsg}');
    };
  }

  void _startListening() async {
    bool isAvailable = await _speech!.initialize();
    if (isAvailable) {
      _speech!.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
        },
      );
    } else {
      print('Speech recognition is not available on this device.');
    }
  }

  void _stopListening() {
    _speech!.stop();
    setState(() {
      _recognizedText = _speech!.lastRecognizedWords ?? '';
      // Perform analysis on the recorded audio (_recognizedText)
      // Send the recorded audio for further processing or analysis
      // Example: make an API call to process the recorded audio
      analyzeAndScoreSpeech(_recognizedText);
    });
  }

  void _sendAudioForAnalysis(String recordedAudio) {
    // Implement the logic to send the recorded audio for analysis
    // Example: make an API call to send the recorded audio
    // You can use the recordedAudio variable to access the transcribed text
    print('Sending audio for analysis: $recordedAudio');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Speech Recognition'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Recognized Text:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              _recognizedText,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _startListening,
              child: Text('Start Listening'),
            ),
            ElevatedButton(
              onPressed: _stopListening,
              child: Text('Stop Listening'),
            ),
          ],
        ),
      ),
    );
  }


  void analyzeAndScoreSpeech(String recognizedText) {
    // Perform analysis on the recognized text
    // Evaluate factors like accuracy, fluency, pronunciation, intonation, etc.

    // Calculate a score based on the analysis

    // Provide feedback and scoring to the user
    // Display the score and suggestions for improvement

    // Example scoring and feedback:
    double accuracyScore = calculateAccuracyScore(recognizedText);
    double fluencyScore = calculateFluencyScore(recognizedText);
    double pronunciationScore = calculatePronunciationScore(recognizedText);
    double intonationScore = calculateIntonationScore(recognizedText);

    double overallScore = (accuracyScore + fluencyScore + pronunciationScore + intonationScore) / 4;

    String feedback = generateFeedback(overallScore);

    print('Score: $overallScore');
    print('Feedback: $feedback');
  }

  double calculateAccuracyScore(String recognizedText) {
    // Implement your logic to calculate accuracy score
    // Example: compare recognized text with expected text and calculate a score

    String expectedText = "Hello, how are you today?";

    // Convert the recognized and expected text to lowercase for case-insensitive comparison
    String recognizedTextLower = recognizedText.toLowerCase();
    String expectedTextLower = expectedText.toLowerCase();

    int matchCount = 0;
    List<String> recognizedWords = recognizedTextLower.split(' ');

    for (String word in recognizedWords) {
      if (expectedTextLower.contains(word)) {
        matchCount++;
      }
    }

    double accuracyScore = matchCount / recognizedWords.length;
    return accuracyScore;
  }

  double calculateFluencyScore(String recognizedText) {
    // Implement your logic to calculate fluency score
    // Example: analyze the flow and coherence of the recognized text and calculate a score

    // Calculate the average word length in the recognized text
    List<String> recognizedWords = recognizedText.split(' ');
    double averageWordLength = recognizedWords.fold(0, (sum, word) => sum + word.length) / recognizedWords.length;

    // Calculate the fluency score based on the average word length
    double fluencyScore = 1 - (averageWordLength / 10); // Assuming 10 is the desired average word length

    return fluencyScore;
  }

  double calculatePronunciationScore(String recognizedText) {
    // Implement your logic to calculate pronunciation score
    // Example: compare the pronunciation of specific words or phonemes with expected pronunciation and calculate a score

    String expectedPronunciation = "həˈloʊ haʊ ɑr ju təˈdeɪ";

    // Convert the recognized and expected pronunciation to lowercase for case-insensitive comparison
    String recognizedPronunciationLower = recognizedText.toLowerCase();
    String expectedPronunciationLower = expectedPronunciation.toLowerCase();

    int matchCount = 0;
    List<String> recognizedPhonemes = recognizedPronunciationLower.split(' ');

    for (String phoneme in recognizedPhonemes) {
      if (expectedPronunciationLower.contains(phoneme)) {
        matchCount++;
      }
    }

    double pronunciationScore = matchCount / recognizedPhonemes.length;
    return pronunciationScore;
  }

  double calculateIntonationScore(String recognizedText) {
    // Implement your logic to calculate intonation score
    // Example: analyze the pitch and melody of the recognized text and calculate a score

    // Calculate the average length of recognized phrases/sentences
    List<String> recognizedSentences = recognizedText.split('.'); // Assuming sentences end with a period
    double averageSentenceLength = recognizedSentences.fold(0, (sum, sentence) => sum + sentence.length) / recognizedSentences.length;

    // Calculate the intonation score based on the average sentence length
    double intonationScore = 1 - (averageSentenceLength / 30); // Assuming 30 is the desired average sentence length

    return intonationScore;
  }


  String generateFeedback(double overallScore) {
    // Implement your logic to generate feedback based on the overall score
    // Example: provide specific suggestions for improvement based on the score range
    if (overallScore >= 0.8) {
      return 'Great job! Your spoken language skills are excellent.';
    } else if (overallScore >= 0.6) {
      return 'Good effort! Focus on improving accuracy and pronunciation.';
    } else {
      return 'Keep practicing! Work on accuracy, fluency, and pronunciation.';
    }
  }
}
