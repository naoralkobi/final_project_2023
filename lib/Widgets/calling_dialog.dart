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

    _dotStream = Stream.periodic(Duration(seconds: 1), (count) => count % 4)
        .timeout(
      Duration(seconds: 15),
      onTimeout: (sink) {
        sink.close();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Call was not answered')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            CircularProgressIndicator(),
            SizedBox(height: 20),
            StreamBuilder<int>(
              stream: _dotStream,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (snapshot.hasData) {
                  return Text('Calling${'.' * snapshot.data!}');
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// class CallingDialog extends StatefulWidget {
//   @override
//   _CallingDialogState createState() => _CallingDialogState();
// }
//
// class _CallingDialogState extends State<CallingDialog> {
//   StreamController<int> _dotStreamController = StreamController<int>();
//   Timer? _dotTimer;
//   Timer? _callTimeoutTimer;
//
//   @override
//   void initState() {
//     super.initState();
//     _startDotTimer();
//     _startCallTimeoutTimer();
//   }
//
//   void _startDotTimer() {
//     int count = 0;
//     _dotTimer = Timer.periodic(Duration(seconds: 1), (timer) {
//       _dotStreamController.add(count % 4);
//       count++;
//     });
//   }
//
//   void _startCallTimeoutTimer() {
//     _callTimeoutTimer = Timer(Duration(seconds: 15), () {
//       _dotTimer?.cancel();
//       _dotStreamController.close();
//       Navigator.of(context).pop();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Call was not answered')),
//       );
//     });
//   }
//
//   @override
//   void dispose() {
//     _dotTimer?.cancel();
//     _callTimeoutTimer?.cancel();
//     _dotStreamController.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Dialog(
//       child: Container(
//         padding: EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 IconButton(
//                   icon: Icon(Icons.close),
//                   onPressed: () {
//                     _callTimeoutTimer?.cancel();
//                     Navigator.of(context).pop();
//                   },
//                 ),
//               ],
//             ),
//             CircularProgressIndicator(),
//             SizedBox(height: 20),
//             StreamBuilder<int>(
//               stream: _dotStreamController.stream,
//               builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
//                 if (snapshot.hasData) {
//                   return Text('Calling${'.' * snapshot.data!}');
//                 } else {
//                   return SizedBox.shrink();
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
