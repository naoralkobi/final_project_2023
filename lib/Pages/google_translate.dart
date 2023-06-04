import 'package:final_project_2023/consts.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final _controller = TextEditingController();
  String _translation = '';
  String _sourceLanguageCode = 'en';
  String _targetLanguageCode = 'es';
  final String apiKey = GOOGLE_API_KEY;

// Mapping of language name to its code
  final Map<String, String> languages = {
    ENGLISH: 'en',
    HEBRREW: 'he',
    ARABIC: 'ar',
    FRENCH: 'fr',
    GERMAN: 'de',
    SPANISH: 'es',
    ITALIAN: 'it',
    PORTUGUESE: 'pt',
  };

  // default value
  String _sourceLanguage = ENGLISH;
  String _targetLanguage = SPANISH;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation Screen'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter a word',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Source Language"),
            DropdownButton<String>(
              isExpanded: true,
              value: _sourceLanguage,
              onChanged: (String? newValue) {
                setState(() {
                  _sourceLanguage = newValue!;
                  _sourceLanguageCode = languages[_sourceLanguage]!;
                });
              },
              items:
                  languages.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text("Target Language"),
            DropdownButton<String>(
              isExpanded: true,
              value: _targetLanguage,
              onChanged: (String? newValue) {
                setState(() {
                  _targetLanguage = newValue!;
                  _targetLanguageCode = languages[_targetLanguage]!;
                });
              },
              items:
                  languages.keys.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var url = Uri.parse(
                    '$GOOGLE_TRANSLATE_SERVER'
                    'q=${_controller.text}'
                    '&source=$_sourceLanguageCode'
                    '&target=$_targetLanguageCode'
                    '&format=text'
                    '&key=$apiKey');
                var response = await http.get(url);
                if (response.statusCode == 200) {
                  var jsonResponse = jsonDecode(response.body);
                  var translatedText =
                      jsonResponse['data']['translations'][0]['translatedText'];
                  setState(() {
                    _translation = translatedText;
                  });
                } else {
                  debugPrint('Request failed with status: ${response.statusCode}.');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Translate'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Translation:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _translation,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
