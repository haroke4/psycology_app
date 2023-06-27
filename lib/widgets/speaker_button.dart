import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../prefabs/colors.dart';

class SpeakerButton extends StatefulWidget {
  final String filePath;

  const SpeakerButton({Key? key, required this.filePath}) : super(key: key);

  @override
  State<SpeakerButton> createState() => SpeakerButtonState();
}

class SpeakerButtonState extends State<SpeakerButton> {
  final _player = AudioPlayer();
  var _playerState = PlayerState.stopped;

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((PlayerState s) {
      if(mounted) {
        setState(() {
        _playerState = s;
      });
      }
    });
    playPressed();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();

  }

  Future<void> playPressed() async{
    if (_playerState == PlayerState.playing) {
      await _player.stop();
      return;
    }
    await _player.play(DeviceFileSource(widget.filePath));
  }

  //Requiered when several appeals подряд идет
  Future<void> stopAndPlayNext() async{
    _player.stop();
    await _player.play(DeviceFileSource(widget.filePath));
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: playPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: lightColor2,
        shape: const CircleBorder(),
      ),
      child: Padding(
        padding: EdgeInsets.all(25.sp),
        child: Icon(
          Icons.multitrack_audio,
          color: lightColor5,
          size: 150.sp,
        ),
      ),
    );
  }
}
