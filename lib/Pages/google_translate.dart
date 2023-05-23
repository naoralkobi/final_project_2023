

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
final String apiKey = 'AIzaSyC_-_XeUsGfdBt4h1fx2ZYYdEC_K_aFAOY';

// Mapping of language name to its code
final Map<String, String> languages = {
'English': 'en',
'Hebrew': 'he',
'Arabic': 'ar',
'French': 'fr',
'German': 'de',
'Spanish': 'es',
'Italian': 'it',
'Portuguese': 'pt',
};

String _sourceLanguage = 'English';
String _targetLanguage = 'Spanish';

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text('Translation Screen'),
backgroundColor: Colors.blue,
),
body: Padding(
padding: const EdgeInsets.all(20.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: <Widget>[
TextField(
controller: _controller,
decoration: InputDecoration(
labelText: 'Enter word',
border: OutlineInputBorder(),
),
),
SizedBox(height: 20),
Text("Source Language"),
DropdownButton<String>(
isExpanded: true,
value: _sourceLanguage,
onChanged: (String? newValue) {
setState(() {
_sourceLanguage = newValue!;
_sourceLanguageCode = languages[_sourceLanguage]!;
});
},
items: languages.keys
    .map<DropdownMenuItem<String>>((String value) {
return DropdownMenuItem<String>(
value: value,
child: Text(value),
);
}).toList(),
),
SizedBox(height: 20),
Text("Target Language"),
DropdownButton<String>(
isExpanded: true,
value: _targetLanguage,
onChanged: (String? newValue) {
setState(() {
_targetLanguage = newValue!;
_targetLanguageCode = languages[_targetLanguage]!;
});
},
items: languages.keys
    .map<DropdownMenuItem<String>>((String value) {
return DropdownMenuItem<String>(
value: value,
child: Text(value),
);
}).toList(),
),
SizedBox(height: 20),
ElevatedButton(
onPressed: () async {
var url = Uri.parse('https://translation.googleapis.com/language/translate/v2?'
'q=${_controller.text}'
'&source=$_sourceLanguageCode'
'&target=$_targetLanguageCode'
'&format=text'
'&key=$apiKey');
var response = await http.get(url);
if (response.statusCode == 200) {
var jsonResponse = jsonDecode(response.body);
var translatedText = jsonResponse['data']['translations'][0]['translatedText'];
setState(() {
_translation = translatedText;
});
} else {
print('Request failed with status: ${response.statusCode}.');
}
},
child: Text('Translate'),
style: ElevatedButton.styleFrom(
primary: Colors.blue,
),
),
SizedBox(height: 20),
Text(
'Translation:',
style: TextStyle(
fontSize: 18,
fontWeight: FontWeight.bold,
),
),
SizedBox(height: 10),
Text(
_translation,
style: TextStyle(fontSize: 20),
),
],
),
),
);
}
}
