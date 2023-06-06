import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../consts.dart';

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
    // Request microphone and camera permissions
    await [Permission.microphone, Permission.camera].request();

    // Create an instance of the Agora RtcEngine
    _engine = await RtcEngine.create(AGORA_API);

    // Enable video
    await _engine?.enableVideo();

    // Set event handlers for the RtcEngine
    _engine?.setEventHandler(
      RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          setState(() {
            debugPrint('Local user $uid joined channel $channel');
          });
        },
        userJoined: (int uid, int elapsed) {
          setState(() {
            debugPrint('Remote user $uid joined channel');
            _remoteUid = uid;
          });
        },
        userOffline: (int uid, UserOfflineReason reason) {
          setState(() {
            debugPrint('Remote user $uid left channel');
            _remoteUid = null;
          });
        },
      ),
    );

    // Join the channel
    await _engine?.joinChannel(null, widget.channelName, null, 0);
  }

  void _finishCall(String callRequestId) {
    // Update the call request status to 'completed'
    FirebaseFirestore.instance
        .collection('call_requests')
        .doc(callRequestId)
        .update({'status': 'completed'});

    // Leave the channel and destroy the RtcEngine instance
    _engine?.leaveChannel();
    _engine?.destroy();

    // Return to the previous page (chat page)
    Navigator.pop(context);
  }

  @override
  void dispose() {
    super.dispose();
    // Leave the channel and destroy the RtcEngine instance
    _engine?.leaveChannel();
    _engine?.destroy();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Call'),
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
            child: SizedBox(
              width: 120,
              height: 160,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  width: 60,
                  height: 80,
                  color: Colors.black54,
                  child: const RtcLocalView.SurfaceView(),
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
                      // Mute/unmute the local audio stream
                      _engine?.muteLocalAudioStream(_mute);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 25,
                  child: IconButton(
                    icon: const Icon(
                      Icons.switch_camera,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Switch camera between front and rear
                      _engine?.switchCamera();
                    },
                  ),
                ),
                const SizedBox(height: 10),
                CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 25,
                  child: IconButton(
                    icon: const Icon(
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
