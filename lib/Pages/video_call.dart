// import 'package:flutter/material.dart';
// import 'package:agora_rtc_engine/rtc_engine.dart';
// import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
// import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class VideoCallPage extends StatefulWidget {
//   final String channelName;
//
//   const VideoCallPage({Key? key, required this.channelName}) : super(key: key);
//
//   @override
//   _VideoCallPageState createState() => _VideoCallPageState();
// }
//
// class _VideoCallPageState extends State<VideoCallPage> {
//   RtcEngine? _engine;
//   bool _mute = false;
//   int? _remoteUid;
//
//   @override
//   void initState() {
//     super.initState();
//     initAgora();
//   }
//
//   Future<void> initAgora() async {
//     await [Permission.microphone, Permission.camera].request();
//
//     _engine = await RtcEngine.create('c8c68b6a28be4e3784eb6d76f6d2fbe0');
//
//     await _engine?.enableVideo();
//
//     _engine?.setEventHandler(
//       RtcEngineEventHandler(
//         joinChannelSuccess: (String channel, int uid, int elapsed) {
//           setState(() {
//             print('Local user $uid joined channel $channel');
//           });
//         },
//         userJoined: (int uid, int elapsed) {
//           setState(() {
//             print('Remote user $uid joined channel');
//             _remoteUid = uid;
//           });
//         },
//         userOffline: (int uid, UserOfflineReason reason) {
//           setState(() {
//             print('Remote user $uid left channel');
//             _remoteUid = null;
//           });
//         },
//       ),
//     );
//
//     await _engine?.joinChannel(null, widget.channelName, null, 0);
//   }
//
//   void _finishCall(String callRequestId) {
//     FirebaseFirestore.instance
//         .collection('call_requests')
//         .doc(callRequestId)
//         .update({'status': 'completed'});
//
//     _engine?.leaveChannel();
//     _engine?.destroy();
//
//     Navigator.pop(context); // Return to the previous page (chat page)
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _engine?.leaveChannel();
//     _engine?.destroy();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Video Call'),
//       ),
//       body: Stack(
//         children: [
//           _remoteUid != null
//               ? RtcRemoteView.SurfaceView(
//             uid: _remoteUid!,
//             channelId: widget.channelName,
//           )
//               : const Text('Waiting for remote user to join...'),
//           Align(
//             alignment: Alignment.bottomRight,
//             child: Container(
//               width: 120,
//               height: 160,
//               child: Stack(
//                 children: [
//                   RtcLocalView.SurfaceView(
//                     renderMode: VideoRenderMode.Hidden,
//                   ),
//                   Align(
//                     alignment: Alignment.bottomRight,
//                     child: Container(
//                       width: 60,
//                       height: 80,
//                       color: Colors.black54,
//                       child: RtcLocalView.SurfaceView(),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomLeft,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 CircleAvatar(
//                   backgroundColor: Colors.grey,
//                   radius: 25,
//                   child: IconButton(
//                     icon: Icon(
//                       _mute ? Icons.mic_off : Icons.mic,
//                       color: Colors.white,
//                     ),
//                     onPressed: () {
//                       setState(() {
//                         _mute = !_mute;
//                       });
//                       _engine?.muteLocalAudioStream(_mute);
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 CircleAvatar(
//                   backgroundColor: Colors.grey,
//                   radius: 25,
//                   child: IconButton(
//                     icon: Icon(
//                       Icons.switch_camera,
//                       color: Colors.white,
//                     ),
//                     onPressed: () {
//                       _engine?.switchCamera();
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 CircleAvatar(
//                   backgroundColor: Colors.grey,
//                   radius: 25,
//                   child: IconButton(
//                     icon: Icon(
//                       Icons.call_end,
//                       color: Colors.white,
//                     ),
//                     onPressed: () {
//                       _finishCall('callRequestId'); // Replace 'callRequestId' with the actual call request ID
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoCallPage extends StatefulWidget {
  final String channelName;

  const VideoCallPage({Key? key, required this.channelName}) : super(key: key);

  @override
  _VideoCallPageState createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  RtcEngine? _engine;
  bool _mute = false;
  int? _remoteUid;

  @override
  void initState() {
    super.initState();
    initAgora();
  }

  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = await RtcEngine.create('c8c68b6a28be4e3784eb6d76f6d2fbe0');

    await _engine?.enableVideo();

    _engine?.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          setState(() {
            print('Local user $uid joined channel $channel');
          });
        },
        userJoined: (int uid, int elapsed) {
          setState(() {
            print('Remote user $uid joined channel');
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          setState(() {
            print('Remote user $uid left channel');
            _remoteUid = null;
          });
        },
      ),
    );

    await _engine?.joinChannel(null, widget.channelName, null, 0);
  }

  void _finishCall(String callRequestId) {
    FirebaseFirestore.instance
        .collection('call_requests')
        .doc(callRequestId)
        .update({'status': 'completed'});

    _engine?.leaveChannel();
    _engine?.destroy();

    Navigator.pop(context); // Return to the previous page (chat page)
  }

  @override
  void dispose() {
    super.dispose();
    _engine?.leaveChannel();
    _engine?.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Call'),
      ),
      body: Stack(
        children: [
          _remoteUid != null
              ? RtcRemoteView.SurfaceView(
            uid: _remoteUid!,
            channelId: widget.channelName,
          )
              : const Text('Waiting for remote user to join...'),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 120,
              height: 160,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 60,
                  height: 80,
                  color: Colors.black54,
                  child: RtcLocalView.SurfaceView(),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 25,
                  child: IconButton(
                    icon: Icon(
                      _mute ? Icons.mic_off : Icons.mic,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _mute = !_mute;
                      });
                      _engine?.muteLocalAudioStream(_mute);
                    },
                  ),
                ),
                SizedBox(height: 10),
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 25,
                  child: IconButton(
                    icon: Icon(
                      Icons.switch_camera,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _engine?.switchCamera();
                    },
                  ),
                ),
                SizedBox(height: 10),
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 25,
                  child: IconButton(
                    icon: Icon(
                      Icons.call_end,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      _finishCall('callRequestId'); // Replace 'callRequestId' with the actual call request ID
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

