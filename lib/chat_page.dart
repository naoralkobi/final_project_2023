import 'package:flutter/material.dart';
import 'package:bubble/bubble.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({Key? key}) : super(key: key);

  @override
  _ChatHomePageState createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  List<String> _messages = [];

  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Home Page'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Show latest message at bottom
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                final message = _messages[index];
                final isMe = index % 2 == 0; // Alternate between user and other user
                return Bubble(
                  alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                  color: isMe ? Colors.blue : Colors.grey.shade200,
                  nip: isMe ? BubbleNip.rightTop : BubbleNip.leftTop,
                  child: Text(message),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a message',
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      final message = _messageController.text;
                      _messages.add(message);
                      _messageController.clear();
                    });
                  },
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}