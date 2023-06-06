import 'dart:async';
import 'package:flutter/material.dart';

class CallingDialog extends StatefulWidget {
  @override
  _CallingDialogState createState() => _CallingDialogState();
}

class _CallingDialogState extends State<CallingDialog> {
  late Stream<int> _dotStream;

  @override
  void initState() {
    super.initState();

    _dotStream = Stream.periodic(const Duration(seconds: 1), (count) => count % 4)
        .timeout(
      const Duration(seconds: 15),
      onTimeout: (sink) {
        sink.close();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Call was not answered')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            StreamBuilder<int>(
              stream: _dotStream,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.hasData) {
                  return Text('Calling${'.' * snapshot.data!}');
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
