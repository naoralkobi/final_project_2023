// import 'dart:math';
// import 'package:avatar_glow/avatar_glow.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:final_project_2023/consts.dart';
// import 'package:flutter/material.dart';
// import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// class SpeechRecognitionScreen extends StatefulWidget {
//
//   final String selectedLanguage;
//   SpeechRecognitionScreen({required this.selectedLanguage});
//
//   @override
//   _SpeechRecognitionScreenState createState() =>
//       _SpeechRecognitionScreenState();
// }
//
// class _SpeechRecognitionScreenState extends State<SpeechRecognitionScreen> {
//   stt.SpeechToText? _speech;
//   String _recognizedText = '';
//   List<Map<String, String>> wordsList = [];
//   late String randomWord = '';
//   late String translation = '';
//   var isListening = false;
//   List<String> parts = [];
//   late String language;
//   late String languageLevel;
//   List<String> unSupportedLanguagesPhoneme = ['Arabic','Hebrew'];
//
//   // Mapping of language to locale
//   Map<String, String> languageToLocale = {
//     ENGLISH: "en_US",
//     ARABIC: "ar_SA",
//     FRENCH: "fr_FR",
//     GERMAN: "de_DE",
//     "Hebrew": "he_IL"
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     parts = widget.selectedLanguage.split("-");
//     language = parts[0];
//     languageLevel = parts[1];
//     FirebaseFirestore.instance
//         .collection(SPEECH_TO_TEXT)
//         .doc(widget.selectedLanguage)
//         .get()
//         .then((value) {
//       List<dynamic> wordsData = List<dynamic>.from(value.data()!['words']);
//       List<Map<String, String>> words = wordsData
//           .map((word) => Map<String, String>.from(word as Map<dynamic, dynamic>))
//           .toList();
//       setState(() {
//         wordsList = words;
//         randomWord = _generateRandomWord();
//       });
//     });
//     _initializeSpeechRecognition();
//   }
//
//   String _generateRandomWord() {
//     final _random = Random();
//     int randomIndex = _random.nextInt(wordsList.length);
//     MapEntry<String, String> randomEntry =
//     wordsList[randomIndex].entries.toList()[_random.nextInt(wordsList[randomIndex].length)];
//     setState(() {
//       randomWord = randomEntry.key;
//       translation = randomEntry.value;
//     });
//     return randomWord;
//   }
//
//
//   Future<void> _updateRandomWord() async {
//     final _random = Random();
//     String currentWord = randomWord;
//     while (currentWord == randomWord) {
//       int randomIndex = _random.nextInt(wordsList.length);
//       MapEntry<String, String> randomEntry =
//       wordsList[randomIndex].entries.toList()[_random.nextInt(wordsList[randomIndex].length)];
//       randomWord = randomEntry.key;
//       translation = randomEntry.value;
//     }
//     setState(() {});
//     return await Future.delayed(const Duration(seconds: 1));
//   }
//
//   Future<void> _initializeSpeechRecognition() async {
//     _speech = stt.SpeechToText();
//     bool isAvailable = await _speech!.initialize(
//       onError: (val) => debugPrint('onError: $val'),
//       onStatus: (val) => debugPrint('onStatus: $val'),
//       debugLogging: true,
//       finalTimeout: const Duration(seconds: 1),
//     );
//     if (isAvailable) {
//       _speech!.errorListener = (error) {
//         debugPrint('Speech recognition error: ${error.errorMsg}');
//       };
//     } else {
//       debugPrint('Speech recognition is not available on this device.');
//     }
//   }
//
//
//   void _startListening() async {
//     if (_speech!.isListening) return;
//     setState(() {
//       _recognizedText = '';
//     });
//     await _speech!.listen(
//       localeId: languageToLocale[widget.selectedLanguage],
//       onResult: (result) {
//         setState(() {
//           _recognizedText = result.recognizedWords;
//         });
//       },
//     );
//   }
//
//   void _stopListening() {
//     if (!_speech!.isListening) return;
//     _speech!.stop();
//     setState(() {
//       // Perform analysis on the recorded audio (_recognizedText)
//       // Send the recorded audio for further processing or analysis
//       // Example: make an API call to process the recorded audio
//       analyzeAndScoreSpeech(_recognizedText);
//       _recognizedText = '';
//     });
//   }
//
//   Color bgColor = const Color(0xff00A67E);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: AvatarGlow(
//         endRadius: 75.0,
//         animate: isListening,
//         duration: const Duration(milliseconds: 2000),
//         glowColor: const Color(0xff00A67E),
//         repeat: true,
//         repeatPauseDuration: const Duration(milliseconds: 100),
//         showTwoGlows: true,
//         child: GestureDetector(
//           onTapDown: (details) {
//             setState(() {
//               isListening = true;
//             });
//
//             calculatePronunciationScore("hello world","hellu world","English");
//
//             _startListening();
//           },
//           onTapUp: (details) {
//             setState(() {
//               isListening = false;
//             });
//             _stopListening();
//           },
//           child: const CircleAvatar(
//             backgroundColor: Color(0xff00A67E),
//             radius: 35,
//             child: Icon(Icons.mic, color: Colors.white),
//           ),
//         ),
//       ),
//       backgroundColor: Colors.grey[200],
//       appBar: AppBar(
//         title: const Text('Speech Recognition'),
//         centerTitle: true,
//         backgroundColor: MAIN_BLUE_COLOR,
//       ),
//       body: Column(
//         children: [
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: Text(
//               'Pull to Refresh',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           const SizedBox(height: 10),
//           Expanded(
//             child: LiquidPullToRefresh(
//               onRefresh: _updateRandomWord,
//               animSpeedFactor: 6,
//               height: 100,
//               child: ListView(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8.0),
//                     color: Colors.grey[300],
//                     child: Column(
//                       children: [
//                         Text(
//                           'Language - $language',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'Level - $languageLevel',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 4),
//                         const Text(
//                           'Press and hold the record button and say the text:',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(25.0),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(15),
//                       child: Container(
//                         color: Colors.blue,
//                         alignment: Alignment.center,
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           children: [
//                             const SizedBox(height: 20),
//                             Text(
//                               _recognizedText,
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             Text(
//                               randomWord,
//                               style: const TextStyle(
//                                 fontSize: 30,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             SizedBox(
//                               height: null,
//                               child: ListView.builder(
//                                 physics: const NeverScrollableScrollPhysics(),
//                                 shrinkWrap: true,
//                                 itemBuilder: (context, index) {
//                                   return const Padding(
//                                     padding: EdgeInsets.all(8.0),
//                                   );
//                                 },
//                                 itemCount: 1,
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             Text(
//                               _recognizedText,
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.black87,
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                               children: [],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 20),
//                     child: Column(
//                       children: [
//                         const Text(
//                           'Translation:',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           translation,
//                           style: const TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   void  analyzeAndScoreSpeech(String recognizedText) {
//     // Perform analysis on the recognized text
//     // Evaluate factors like accuracy, fluency, pronunciation, intonation, etc.
//
//
//     // scoring:
//      double overallScore = 0;
//
//      double hammingDistance = calculateHammingDistance(recognizedText, randomWord);
//      double accuracyScore = calculateAccuracyScore(recognizedText, randomWord);
//      double fluencyScore = calculateFluencyScore(recognizedText);
//      double intonationScore = calculateIntonationScore(recognizedText);
//
//      if (!unSupportedLanguagesPhoneme.contains(language))
//      {
//          double pronunciationScore = calculatePronunciationScore(randomWord, recognizedText, language) as double;
//          // Calculate a score based on the analysis
//           overallScore = (accuracyScore + fluencyScore + pronunciationScore + intonationScore + hammingDistance) / 5;
//      }
//      else
//      {
//         overallScore = (accuracyScore + fluencyScore  + intonationScore + hammingDistance) / 4;
//      }
//
//     String feedback = generateFeedback(overallScore);
//
//      // Provide feedback and scoring to the user
//      // Display the score and suggestions for improvement
//     _showScore(overallScore,feedback);
//
//      debugPrint('Score: $hammingDistance');
//      debugPrint('Feedback: $feedback');
//   }
//
//
//
//   Future<void> _showScore(double score, String feedback) async {
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Your score is $score.'),
//           content: Text(feedback),
//           actions: <Widget>[
//             TextButton(
//               child: const Text('OK'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
// }
//
// double calculateHammingDistance(String recognizedText, String randomWord) {
//   int distance = 0;
//   int maxLength = recognizedText.length > randomWord.length ? recognizedText.length : randomWord.length;
//
//   // Iterate through each character position
//   for (int i = 0; i < maxLength; i++) {
//     // Check if one of the strings is shorter than the other
//     if (i >= recognizedText.length || i >= randomWord.length) {
//       distance += 1; // Increment distance by 1
//     }
//     // Check if the characters at the current position are different
//     else if (recognizedText[i] != randomWord[i]) {
//       distance += 1; // Increment distance by 1
//     }
//   }
//
//   // Calculate the similarity as a ratio between the distance and the maximum length
//   return 1 - (distance / maxLength);
// }
//
//
//
// double calculateAccuracyScore(String recognizedText, String expectedText) {
//   //compare recognized text with expected text and calculate a score
//
//   // Convert the recognized and expected text to lowercase for case-insensitive comparison
//   String recognizedTextLower = recognizedText.toLowerCase();
//   String expectedTextLower = expectedText.toLowerCase();
//
//   int matchCount = 0;
//   List<String> recognizedWords = recognizedTextLower.split(' ');
//
//   // Iterate through each word in the recognized text
//   for (String word in recognizedWords) {
//     // Check if the word exists in the expected text
//     if (expectedTextLower.contains(word)) {
//       matchCount++; // Increment the match count if the word is found
//     }
//   }
//
//   // Calculate the accuracy score as a ratio between the match count and the number of recognized words
//   double accuracyScore = matchCount / recognizedWords.length;
//   return accuracyScore;
// }
//
// double calculateFluencyScore(String recognizedText) {
//  //analyze the flow and coherence of the recognized text and calculate a score
//
//   // Calculate the average word length in the recognized text
//   List<String> recognizedWords = recognizedText.split(' ');
//   double averageWordLength = recognizedWords.fold(0, (sum, word) => sum + word.length) / recognizedWords.length;
//
//   // Calculate the fluency score based on the average word length
//   double fluencyScore = 1 - (averageWordLength / 10); // Assuming 10 is the desired average word length
//
//   return fluencyScore;
// }
//
//
// double calculateIntonationScore(String recognizedText) {
//   // Calculate the average length of recognized phrases/sentences
//   List<String> recognizedSentences = recognizedText.split('.'); // Assuming sentences end with a period
//   double averageSentenceLength = recognizedSentences.fold(0, (sum, sentence) => sum + sentence.length) / recognizedSentences.length;
//
//   // Calculate the intonation score based on the average sentence length
//   double intonationScore = 1 - (averageSentenceLength / 30); // Assuming 30 is the desired average sentence length
//
//   return intonationScore;
// }
//
//
// Future<String> textToPhonemes(String text, String language) async {
//   final response = await http.post(
//     Uri.https('ttp-wrni42euaa-ew.a.run.app', '/text_to_phonemes'),
//     headers: <String, String>{
//       'Content-Type': 'application/json; charset=UTF-8',
//     },
//     body: jsonEncode(<String, String>{
//       'text': text,
//       'language': language,
//     }),
//   );
//
//   if (response.statusCode == 200) {
//     // If the server returns a 200 OK response,
//     // then parse the JSON.
//     return jsonDecode(response.body)['phonemes'];
//   } else {
//     // If the server did not return a 200 OK response,
//     // then throw an exception.
//     throw Exception('Failed to convert text to phonemes.');
//   }
// }
//
// Future<double> calculatePronunciationScore(String originalText, String recognizedText, String language) async {
//   String originalPhonemes = await textToPhonemes(originalText, language);
//   String recognizedPhonemes = await textToPhonemes(recognizedText, language);
//
//   debugPrint(originalPhonemes);
//   debugPrint(recognizedPhonemes);
//   // Now compare originalPhonemes and recognizedPhonemes.
//   // using Levenshtein distance.
//
//   return levenshteinDistance(originalPhonemes, recognizedPhonemes);
// }
//
// double levenshteinDistance(String s, String t) {
//   // If both strings are equal, the distance is zero
//   if (s == t) return 0.0;
//
//   // If one string is empty, the distance is the length of the other string
//   if (s.isEmpty) return t.length.toDouble();
//   if (t.isEmpty) return s.length.toDouble();
//
//   // Create two work vectors of integer distances
//   List<int> v0 = List<int>.filled(t.length + 1, 0);
//   List<int> v1 = List<int>.filled(t.length + 1, 0);
//
//   // Initialize v0 (previous row of distances)
//   // Edit distance for an empty s is just the number of characters in t
//   for (int i = 0; i < t.length + 1; i++) {
//     v0[i] = i;
//   }
//
//   // Calculate v1 (current row distances) from the previous row v0
//   for (int i = 0; i < s.length; i++) {
//     // First element of v1 is s substring edit distance to an empty t
//     v1[0] = i + 1;
//
//     // Use formula to fill in the rest of the row
//     for (int j = 0; j < t.length; j++) {
//       // Calculate cost. It's 0 if characters at the corresponding position in both strings are same, otherwise 1.
//       int cost = s.codeUnits[i] == t.codeUnits[j] ? 0 : 1;
//
//       // Minimum of cell to the left+1, to the top+1, diagonally left and up +cost
//       v1[j + 1] = min(min(v1[j] + 1, v0[j + 1] + 1), v0[j] + cost);
//     }
//
//     // Copy v1 (current row) to v0 (previous row) for next iteration
//     // Since data in v1 is always invalidated, a swap is more efficient
//     List<int> tmp = v0;
//     v0 = v1;
//     v1 = tmp;
//   }
//
//   // After the final swap, the result is in v0
//   int levenshteinDistance = v0[t.length];
//
//   // Calculate the maximum length between the two strings
//   int maxLength = max(s.length, t.length);
//
//   // Normalize the distance between 0 and 1
//   double normalizedDistance = 1 - (levenshteinDistance / maxLength.toDouble());
//
//   return normalizedDistance;
// }
//
//
//
//
// String generateFeedback(double overallScore) {
//   // Implement your logic to generate feedback based on the overall score
//   // Example: provide specific suggestions for improvement based on the score range
//   if (overallScore >= 0.8) {
//     return 'Great job! Your spoken language skills are excellent.';
//   } else if (overallScore >= 0.6) {
//     return 'Good effort! Focus on improving accuracy and pronunciation.';
//   } else {
//     return 'Keep practicing! Work on accuracy, fluency, and pronunciation.';
//   }
// }
//

import 'dart:math';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project_2023/consts.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart' show PlatformException, rootBundle;

import 'dart:io';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:google_speech/google_speech.dart';
import 'package:google_speech/speech_client_authenticator.dart';
import 'package:path_provider/path_provider.dart';

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
  List<Map<String, String>> wordsList = [];
  late String randomWord = '';
  late String translation = '';
  var isListening = false;
  List<String> parts = [];
  late String language;
  late String languageLevel;
  List<String> unSupportedLanguagesPhoneme = ['Arabic', 'Hebrew'];

  // Mapping of language to locale
  // Map<String, String> languageToLocale = {
  //   ENGLISH: "en_US",
  //   ARABIC: "ar_SA",
  //   FRENCH: "fr_FR",
  //   GERMAN: "de_DE",
  //   "Hebrew": "he_IL"
  // };
  Map<String, String> languageToLocale = {
    "English": "en-US",
    ARABIC: "ar-SA",
    FRENCH: "fr-FR",
    GERMAN: "de-DE",
    HEBREW: "he-IL",
    ITALIAN: "it-IT",
    SPANISH: "es-ES",
    PORTUGUESE: "pt-PT"
  };

  /// todo - maybe remove:

  FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  late String _audioFilePath;

  ///////////

  @override
  void initState() {
    super.initState();
    parts = widget.selectedLanguage.split("-");
    language = parts[0];
    languageLevel = parts[1];
    FirebaseFirestore.instance
        .collection("speech_to_text")
        .doc(widget.selectedLanguage)
        .get()
        .then((value) {
      List<dynamic> wordsData = List<dynamic>.from(value.data()!['words']);
      List<Map<String, String>> words = wordsData
          .map(
              (word) => Map<String, String>.from(word as Map<dynamic, dynamic>))
          .toList();
      setState(() {
        //wordsList = words.map((word) => word.keys.first).toList();
        wordsList = words;
        randomWord = _generateRandomWord();
      });
    });
    //_initializeSpeechRecognition();
    _recorder.openAudioSession();
  }

  String _generateRandomWord() {
    final _random = Random();
    int randomIndex = _random.nextInt(wordsList.length);
    MapEntry<String, String> randomEntry = wordsList[randomIndex]
        .entries
        .toList()[_random.nextInt(wordsList[randomIndex].length)];
    setState(() {
      randomWord = randomEntry.key;
      translation = randomEntry.value;
    });
    return randomWord;
  }

  Future<void> _updateRandomWord() async {
    final _random = Random();
    String currentWord = randomWord;
    while (currentWord == randomWord) {
      int randomIndex = _random.nextInt(wordsList.length);
      MapEntry<String, String> randomEntry = wordsList[randomIndex]
          .entries
          .toList()[_random.nextInt(wordsList[randomIndex].length)];
      randomWord = randomEntry.key;
      translation = randomEntry.value;
    }
    setState(() {});
    return await Future.delayed(Duration(seconds: 1));
  }

  Future<void> _initializeSpeechRecognition() async {
    _speech = stt.SpeechToText();
    bool isAvailable = await _speech!.initialize(
      onError: (val) => print('onError: $val'),
      onStatus: (val) => print('onStatus: $val'),
      debugLogging: true,
      finalTimeout: const Duration(seconds: 1),
    );
    if (isAvailable) {
      _speech!.errorListener = (error) {
        print('Speech recognition error: ${error.errorMsg}');
      };
    } else {
      print('Speech recognition is not available on this device.');
    }
  }

  void _startRecording() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        debugPrint("in start recording");
        await _recorder.openAudioSession();
        var tempDir = await getApplicationDocumentsDirectory();
        final directory = Directory(tempDir.path);
        await directory.create(recursive: true);

        final directoryPath = directory.path;
        _audioFilePath = '$directoryPath/flutter_sound_lite_temp_record.wav';

        await _recorder.startRecorder(
          toFile: _audioFilePath,
          codec: Codec.pcm16,
          sampleRate: 16000,
          numChannels: 1,
        );
      }
    }
  }


  void _stopRecording() async {
    await _recorder.stopRecorder();
    await _recorder.closeAudioSession();

    final directory = await getApplicationDocumentsDirectory();
    _audioFilePath = '${directory.path}/flutter_sound_lite_temp_record.wav';

    String jsonString = await rootBundle.loadString('assets/service.json');
    final serviceAccount = ServiceAccount.fromString(jsonString);
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    final config = RecognitionConfig(
      encoding: AudioEncoding.LINEAR16,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: languageToLocale[widget.selectedLanguage] ?? 'en-US',
    );

    final file = File(_audioFilePath);
    if (await file.exists()) {
      final audio = await file.readAsBytes();
      final response = await speechToText.recognize(config, audio);

      _recognizedText = response.results
          .map((result) => result.alternatives.first.transcript)
          .join('\n');
      analyzeAndScoreSpeech(_recognizedText);
    } else {
      // File does not exist
      print('Audio file not found at $_audioFilePath');
    }
  }


  ///

  void _startListening() async {
    if (_speech!.isListening) return;
    setState(() {
      _recognizedText = '';
    });
    await _speech!.listen(
      localeId: languageToLocale[widget.selectedLanguage],
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
    debugPrint('Sending audio for analysis: $recordedAudio');
  }

  void sendAudioToGoogleSpeech() async {
    String jsonString = await rootBundle.loadString('assets/service.json');
    final serviceAccount  = ServiceAccount.fromString(jsonString);
    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);
    final config = RecognitionConfig(
        encoding: AudioEncoding.OGG_OPUS,
        model: RecognitionModel.basic,
        enableAutomaticPunctuation: true,
        sampleRateHertz: 16000, // Make sure to adjust this to the sample rate of your audio file
        languageCode: 'he-IL'
    );
    // Adjust this line to the actual path of your audio file
    final audioFilePath = 'assets/audio/record1.ogg';
    final audioFileBytes = await rootBundle.load(audioFilePath);
    final audio = audioFileBytes.buffer.asUint8List().toList();

    final response = await speechToText.recognize(config, audio);

    // Do something with the response
    print(response);
  }


    Color bgColor = const Color(0xff00A67E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        endRadius: 75.0,
        animate: isListening,
        duration: const Duration(milliseconds: 2000),
        glowColor: const Color(0xff00A67E),
        repeat: true,
        repeatPauseDuration: const Duration(milliseconds: 100),
        showTwoGlows: true,
        child: GestureDetector(
          onTapDown: (details) {
            setState(() {
              isListening = true;
            });

            //_startListening();
            _startRecording();
          },
          onTapUp: (details) {
            setState(() {
              isListening = false;
            });
             _stopRecording();
            //_startRecording();
          },
          child: const CircleAvatar(
            backgroundColor: Color(0xff00A67E),
            radius: 35,
            child: Icon(Icons.mic, color: Colors.white),
          ),
        ),
      ),
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Speech Recognition'),
        centerTitle: true,
        backgroundColor: MAIN_BLUE_COLOR,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Pull to Refresh',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: LiquidPullToRefresh(
              onRefresh: _updateRandomWord,
              animSpeedFactor: 6,
              height: 100,
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.grey[300],
                    child: Column(
                      children: [
                        Text(
                          'Language - $language',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Level - $languageLevel',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Press and hold the record button and say the text:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Container(
                        color: Colors.blue,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              randomWord,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(
                              height: null,
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return const Padding(
                                    padding: EdgeInsets.all(8.0),
                                  );
                                },
                                itemCount: 1,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const SizedBox(height: 20),
                            Text(
                              _recognizedText,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: const [],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const Text(
                          'Translation:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          translation,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void analyzeAndScoreSpeech(String recognizedText) {
    // Perform analysis on the recognized text
    // Evaluate factors like accuracy, fluency, pronunciation, intonation, etc.

    // scoring:
    double overallScore = 0;

    double hammingDistance =
        calculateHammingDistance(recognizedText, randomWord);
    double accuracyScore = calculateAccuracyScore(recognizedText, randomWord);
    double fluencyScore = calculateFluencyScore(recognizedText);
    double intonationScore = calculateIntonationScore(recognizedText);

    if (!unSupportedLanguagesPhoneme.contains(language)) {
      double pronunciationScore =
          calculatePronunciationScore(randomWord, recognizedText, language)
              as double;
      // Calculate a score based on the analysis
      overallScore = (accuracyScore +
              fluencyScore +
              pronunciationScore +
              intonationScore +
              hammingDistance) /
          5;
    } else {
      overallScore =
          (accuracyScore + fluencyScore + intonationScore + hammingDistance) /
              4;
    }

    String feedback = generateFeedback(overallScore);

    // Provide feedback and scoring to the user
    // Display the score and suggestions for improvement
    _showScore(overallScore, feedback);

    print('Score: $hammingDistance');
    print('Feedback: $feedback');
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
              child: const Text('OK'),
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

double calculateHammingDistance(String recognizedText, String randomWord) {
  int distance = 0;
  int maxLength = recognizedText.length > randomWord.length
      ? recognizedText.length
      : randomWord.length;

  // Iterate through each character position
  for (int i = 0; i < maxLength; i++) {
    // Check if one of the strings is shorter than the other
    if (i >= recognizedText.length || i >= randomWord.length) {
      distance += 1; // Increment distance by 1
    }
    // Check if the characters at the current position are different
    else if (recognizedText[i] != randomWord[i]) {
      distance += 1; // Increment distance by 1
    }
  }

  // Calculate the similarity as a ratio between the distance and the maximum length
  return 1 - (distance / maxLength);
}

double calculateAccuracyScore(String recognizedText, String expectedText) {
  //compare recognized text with expected text and calculate a score

  // Convert the recognized and expected text to lowercase for case-insensitive comparison
  String recognizedTextLower = recognizedText.toLowerCase();
  String expectedTextLower = expectedText.toLowerCase();

  int matchCount = 0;
  List<String> recognizedWords = recognizedTextLower.split(' ');

  // Iterate through each word in the recognized text
  for (String word in recognizedWords) {
    // Check if the word exists in the expected text
    if (expectedTextLower.contains(word)) {
      matchCount++; // Increment the match count if the word is found
    }
  }

  // Calculate the accuracy score as a ratio between the match count and the number of recognized words
  double accuracyScore = matchCount / recognizedWords.length;
  return accuracyScore;
}

double calculateFluencyScore(String recognizedText) {
  //analyze the flow and coherence of the recognized text and calculate a score

  // Calculate the average word length in the recognized text
  List<String> recognizedWords = recognizedText.split(' ');
  double averageWordLength =
      recognizedWords.fold(0, (sum, word) => sum + word.length) /
          recognizedWords.length;

  // Calculate the fluency score based on the average word length
  double fluencyScore = 1 -
      (averageWordLength /
          10); // Assuming 10 is the desired average word length

  return fluencyScore;
}

double calculateIntonationScore(String recognizedText) {
  // Calculate the average length of recognized phrases/sentences
  List<String> recognizedSentences =
      recognizedText.split('.'); // Assuming sentences end with a period
  double averageSentenceLength =
      recognizedSentences.fold(0, (sum, sentence) => sum + sentence.length) /
          recognizedSentences.length;

  // Calculate the intonation score based on the average sentence length
  double intonationScore = 1 -
      (averageSentenceLength /
          30); // Assuming 30 is the desired average sentence length

  return intonationScore;
}

Future<String> textToPhonemes(String text, String language) async {
  final response = await http.post(
    Uri.https('ttp-wrni42euaa-ew.a.run.app', '/text_to_phonemes'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'text': text,
      'language': language,
    }),
  );

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response,
    // then parse the JSON.
    return jsonDecode(response.body)['phonemes'];
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to convert text to phonemes.');
  }
}

Future<double> calculatePronunciationScore(
    String originalText, String recognizedText, String language) async {
  String originalPhonemes = await textToPhonemes(originalText, language);
  String recognizedPhonemes = await textToPhonemes(recognizedText, language);

  debugPrint(originalPhonemes);
  debugPrint(recognizedPhonemes);
  // Now compare originalPhonemes and recognizedPhonemes.
  // using Levenshtein distance.

  return levenshteinDistance(originalPhonemes, recognizedPhonemes);
}

double levenshteinDistance(String s, String t) {
  // If both strings are equal, the distance is zero
  if (s == t) return 0.0;

  // If one string is empty, the distance is the length of the other string
  if (s.isEmpty) return t.length.toDouble();
  if (t.isEmpty) return s.length.toDouble();

  // Create two work vectors of integer distances
  List<int> v0 = List<int>.filled(t.length + 1, 0);
  List<int> v1 = List<int>.filled(t.length + 1, 0);

  // Initialize v0 (previous row of distances)
  // Edit distance for an empty s is just the number of characters in t
  for (int i = 0; i < t.length + 1; i++) {
    v0[i] = i;
  }

  // Calculate v1 (current row distances) from the previous row v0
  for (int i = 0; i < s.length; i++) {
    // First element of v1 is s substring edit distance to an empty t
    v1[0] = i + 1;

    // Use formula to fill in the rest of the row
    for (int j = 0; j < t.length; j++) {
      // Calculate cost. It's 0 if characters at the corresponding position in both strings are same, otherwise 1.
      int cost = s.codeUnits[i] == t.codeUnits[j] ? 0 : 1;

      // Minimum of cell to the left+1, to the top+1, diagonally left and up +cost
      v1[j + 1] = min(min(v1[j] + 1, v0[j + 1] + 1), v0[j] + cost);
    }

    // Copy v1 (current row) to v0 (previous row) for next iteration
    // Since data in v1 is always invalidated, a swap is more efficient
    List<int> tmp = v0;
    v0 = v1;
    v1 = tmp;
  }

  // After the final swap, the result is in v0
  int levenshteinDistance = v0[t.length];

  // Calculate the maximum length between the two strings
  int maxLength = max(s.length, t.length);

  // Normalize the distance between 0 and 1
  double normalizedDistance =
      1 - (levenshteinDistance / maxLength.toDouble());

  return normalizedDistance;
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
