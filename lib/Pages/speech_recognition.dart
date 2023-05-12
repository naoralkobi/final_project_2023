import 'dart:math';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart' show PlatformException;

class SpeechRecognitionScreen extends StatefulWidget {

  final String selectedLanguage;

  SpeechRecognitionScreen({required this.selectedLanguage});

  @override
  _SpeechRecognitionScreenState createState() =>
      _SpeechRecognitionScreenState();
}

class _SpeechRecognitionScreenState extends State<SpeechRecognitionScreen> {
  stt.SpeechToText? _speech;
  String _recognizedText = '';
  List<String> wordsList = [];
  late String randomWord;
  var isListening = false;

  @override
  @override
  void initState() {
    super.initState();

    FirebaseFirestore.instance
        .collection('speech_to_text')
        .doc(widget.selectedLanguage)
        .get()
        .then((value) {
      Map words = value.data()!['words'];
      setState(() {
        words.forEach((key, value) {
          wordsList.add(value);
        });
        randomWord = _generateRandomWord();
      });
    });
    _initializeSpeechRecognition();
  }

  String _generateRandomWord() {
    final _random = Random();
    return wordsList[_random.nextInt(wordsList.length)];
  }

  Future<void> _updateRandomWord() async{
    final _random = Random();
    String currentWord = randomWord;
    while (currentWord == randomWord) {
      randomWord = wordsList[_random.nextInt(wordsList.length)];
    }
    setState(() {});
    return await Future.delayed(Duration(seconds: 1));
  }

  Future<void> _initializeSpeechRecognition() async {
    _speech = stt.SpeechToText();
    bool isAvailable = await _speech!.initialize();
    if (isAvailable) {
      _speech!.errorListener = (error) {
        print('Speech recognition error: ${error.errorMsg}');
      };
      setState(() {
        _speech!.listen(
          onResult: (result) {
            setState(() {
              _recognizedText = result.recognizedWords;
            });
          },
        );
      });
    } else {
      print('Speech recognition is not available on this device.');
    }
  }

  void _startListening() async {
    if (_speech!.isListening) return;
    setState(() {
      _recognizedText = '';
    });
    await _speech!.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
    );
  }

  void _stopListening() {
    if (!_speech!.isListening) return;
    _speech!.stop();
    setState(() {
      // Perform analysis on the recorded audio (_recognizedText)
      // Send the recorded audio for further processing or analysis
      // Example: make an API call to process the recorded audio
      analyzeAndScoreSpeech(_recognizedText);
      _recognizedText = '';
    });
  }

  void _sendAudioForAnalysis(String recordedAudio) {
    // Implement the logic to send the recorded audio for analysis
    // Example: make an API call to send the recorded audio
    // You can use the recordedAudio variable to access the transcribed text
    print('Sending audio for analysis: $recordedAudio');
  }

  // @override
  // Widget build(BuildContext context) {
  //   randomWord = _generateRandomWord();
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Speech Recognition'),
  //     ),
  //     body: Center(
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text(
  //             '${widget.selectedLanguage}: $_recognizedText',
  //             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //           ),
  //           SizedBox(height: 10),
  //           Text(
  //             // Get a random word from the list
  //             randomWord,
  //             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //           ),
  //           SizedBox(height: 10),
  //           // Expanded(
  //           //   child: ListView.builder(
  //           //     itemCount: wordsList.length,
  //           //     itemBuilder: (context, index) {
  //           //       return Padding(
  //           //         padding: const EdgeInsets.all(8.0),
  //           //         child: Text(
  //           //           wordsList[index],
  //           //           style: TextStyle(
  //           //             fontSize: 16,
  //           //           ),
  //           //         ),
  //           //       );
  //           //     },
  //           //   ),
  //           // ),
  //           Text(
  //             _recognizedText,
  //             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
  //           ),
  //           SizedBox(height: 20),
  //           ElevatedButton(
  //             onPressed: _startListening,
  //             child: Text('Start Listening'),
  //           ),
  //           ElevatedButton(
  //             onPressed: _stopListening,
  //             child: Text('Stop Listening'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               setState(() {
  //                 _updateRandomWord();
  //               });
  //             },
  //             child: Icon(Icons.refresh),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  Color bgColor= Color(0xff00A67E);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
          endRadius: 75.0,
          animate: isListening,
        duration: Duration(milliseconds: 2000),
        glowColor: Color(0xff00A67E),
        repeat: true,
        repeatPauseDuration: Duration(milliseconds: 100),
        showTwoGlows: true,
        child: GestureDetector(
          onTapDown: (details) {
            setState(() {
              isListening = true;
            });
            _startListening();
          },
          onTapUp: (details) {
            setState(() {
              isListening = false;
            });
            _stopListening();
          },
          child:  CircleAvatar(
          backgroundColor: Color(0xff00A67E),
          radius: 35,
          child: Icon(Icons.mic, color: Colors.white),
        ),
        )
      ),
      backgroundColor: Colors.grey[200], // Set background color
      appBar: AppBar(
        title: Text('Speech Recognition'),
        centerTitle: true, // Center app bar title
        backgroundColor: Colors.blue, // Set app bar background color
      ),
      body: LiquidPullToRefresh(
        onRefresh: _updateRandomWord,
        animSpeedFactor: 2,
        height: 100,
        child: ListView(
          children: [
            Padding(
                padding: const EdgeInsets.all(25.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    color: Colors.blue,
                    height: 300,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(16.0), // Add some padding
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 20),
                        Text(
                          '${widget.selectedLanguage}: $_recognizedText',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          randomWord,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          _recognizedText,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ),
          ],
        ),
    ),
    );
  }

  void  analyzeAndScoreSpeech(String recognizedText) {
    // Perform analysis on the recognized text
    // Evaluate factors like accuracy, fluency, pronunciation, intonation, etc.

    // Calculate a score based on the analysis

    // Provide feedback and scoring to the user
    // Display the score and suggestions for improvement

    // scoring and feedback:
    double hammingDistance = calculateHammingDistance(recognizedText, randomWord);
    // double accuracyScore = calculateAccuracyScore(recognizedText);
    // double fluencyScore = calculateFluencyScore(recognizedText);
    // double pronunciationScore = calculatePronunciationScore(recognizedText);
    // double intonationScore = calculateIntonationScore(recognizedText);
    //
    // double overallScore = (accuracyScore + fluencyScore + pronunciationScore + intonationScore) / 4;

    String feedback = generateFeedback(hammingDistance);

    _showScore(hammingDistance,feedback);

    print('Score: $hammingDistance');
    print('Feedback: $feedback');
  }

  double calculateHammingDistance(String recognizedText, String randomWord) {

    int distance = 0;
    int maxLength = recognizedText.length > randomWord.length ? recognizedText.length : randomWord.length;
    for (int i = 0; i < maxLength; i++) {
      if (i >= recognizedText.length || i >= randomWord.length) {
        distance += 1;
      } else if (recognizedText[i] != randomWord[i]) {
        distance += 1;
      }
    }
    return 1 - (distance / maxLength);
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

  Future<void> _showScore(double score, String feedback) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Your score is $score.'),
          content: Text(feedback),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

}
