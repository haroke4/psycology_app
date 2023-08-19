import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../controllers/main_page_controller.dart';
import '../prefabs/colors.dart';

class SpeakerButton extends StatefulWidget {
  const SpeakerButton({Key? key}) : super(key: key);

  @override
  State<SpeakerButton> createState() => SpeakerButtonState();
}

class SpeakerButtonState extends State<SpeakerButton> {
  final _mainController = Get.find<MainPageController>();
  // late final _player;
  // bool _started = false;
  //
  // @override
  // void initState() {
  //   print(widget.filePath);
  //   _player = _mainController.getAudioPlayer;
  //   super.initState();
  //
  //   _player.playbackEventStream.listen((event) {
  //     if (mounted) {
  //       setState(() {
  //         if (event.processingState == ProcessingState.completed && _started) {
  //           _mainController.startVoiceRecognition();
  //           _started = false;
  //         } else if (event.processingState == ProcessingState.idle &&
  //             _started) {
  //           _mainController.startVoiceRecognition();
  //           _started = false;
  //         }
  //       });
  //     }
  //   });
  //
  //   if (_mainController.settingsAutoplay.value) playAudio();
  // }
  //
  //
  // Future<void> playAudio() async {
  //   if (_player.playing == true) {
  //     await _player.stop();
  //   }
  //
  //   await _player.setFilePath(widget.filePath);
  //   await _player.play();
  //   _started = true;
  // }
  //
  // //Requiered when several appeals подряд идет
  // Future<void> stopAndPlayNext() async {
  //   _player.stop();
  //   _player.setFilePath(widget.filePath);
  //   await _player.play();
  //   _started = true;
  // }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _mainController.startVoiceRecognition,
      style: ElevatedButton.styleFrom(
        backgroundColor: lightColor2,
        shape: const CircleBorder(),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(25.sp, 42.sp, 25.sp, 25.sp),
        child: Icon(
          Icons.mic_rounded,
          color: lightColor5,
          size: 150.sp,
        ),
      ),
    );
  }
}
