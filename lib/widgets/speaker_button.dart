
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../controllers/main_page_controller.dart';
import '../prefabs/colors.dart';

class SpeakerButton extends StatefulWidget {
  final String filePath;

  const SpeakerButton({Key? key, required this.filePath}) : super(key: key);

  @override
  State<SpeakerButton> createState() => SpeakerButtonState();
}

class SpeakerButtonState extends State<SpeakerButton> {
  final _player = AudioPlayer();
  bool started = false;

  @override
  void initState() {
    super.initState();
    var mainController = Get.find<MainPageController>();

    _player.playbackEventStream.listen((event) {
      if (mounted) {
        setState(() {
          if (event.processingState == ProcessingState.completed && started) {
            mainController.startVoiceRecognition();
            started = false;
          }
          else if (event.processingState == ProcessingState.idle && started){
            mainController.startVoiceRecognition();
            started = false;
          }
        });
      }
    });

    // _player.onPlayerStateChanged.listen((PlayerState s) {
    //   if (mounted) {
    //     setState(() {
    //       _playerState = s;
    //     });
    //     if (s == PlayerState.completed || s == PlayerState.stopped) {
    //
    //     }
    //   }
    // });
    if (mainController.settingsAutoplay.value) playPressed();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> playPressed() async {
    print('Я 2 КОНЧЕННЫЙ');

    if (_player.playing == true) {
      _player.stop();
      return;
    }
    _player.setFilePath(widget.filePath);
    await _player.play();
    started = true;

  }

  //Requiered when several appeals подряд идет
  Future<void> stopAndPlayNext() async {
    print('Я 1 КОНЧЕННЫЙ');
    _player.stop();
    _player.setFilePath(widget.filePath);
    await _player.play();
    started = true;

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
