import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:psychology_app/main.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:string_similarity/string_similarity.dart';

import '../models/action_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import 'main_page_controller.dart';

class AudioAndVoiceRecController {
  late MainPageController _mainController;
  final SpeechToText _speechToText = SpeechToText();
  final _audioPlayer = AudioPlayer();
  bool _startVoiceRecognitionAfterAudioEnds = false;

  AudioPlayer get getAudioPlayer => _audioPlayer;

  int _recognitionTries = 0;
  List<dynamic> _noVoiceRecognitionModels = [];
  String _recognizedWords = '';

  bool _fakeVoiceRecognitionState = false; // false - play StartVoiceRecFile

  // consts
  final _voiceRecRetryAudioPath = "assets/retry.mp3";
  final _voiceRecStartAudioPath = "assets/sounds/speech_to_text_listening.m4r";
  final _voiceRecStopAudioPath = "assets/sounds/speech_to_text_stop.m4r";

  void initialize(MainPageController mainController) async {
    print("suka INIT");
    _mainController = mainController;

    //
    var speechToTextStatus = await _speechToText.initialize();
    if (!speechToTextStatus) {
      showSnackBarMessage(
          'Голосовое управление не поддерживается на этом устройстве');
    }

    // Если нечего не распознал, пытаемся еще и еще раз
    _speechToText.errorListener = (SpeechRecognitionError data) async {
      showSnackBarMessage(data.toString());
      if (data.errorMsg == 'error_no_match' ||
          data.errorMsg == 'error_speech_timeout') {
        if (_recognizedWords == '' && _recognitionTries < 1) {
          await _speechToText.stop();
          await _audioPlayer.stop();
          await _audioPlayer.setAsset(_voiceRecRetryAudioPath);
          await _audioPlayer.play();
        }
      }
    };

    //
    _audioPlayer.playbackEventStream.listen((event) {
      if (event.processingState == ProcessingState.completed &&
          _startVoiceRecognitionAfterAudioEnds) {
        _mainController.startVoiceRecognition();
        _startVoiceRecognitionAfterAudioEnds = false;
      }
    });
  }

  void setNoVoiceRecognitionModels(List data) {
    _noVoiceRecognitionModels = data;
  }

  void playAppealActionAudio() {
    if (_mainController.settingsAutoplay.value) {
      var path = _mainController.getCurrentActionAudioPath();
      _startVoiceRecognitionAfterAudioEnds = true;
      _audioPlayer.setFilePath(path);
      _audioPlayer.play();
    }
  }

  // voice recognition
  Future<void> stopVoiceRecognition() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  Future<void> startVoiceRecognition({
    silent = false,
    incrementTries = false,
  }) async {
    _startVoiceRecognitionAfterAudioEnds = false;

    // filters
    for (var i in _mainController.currentPage) {
      if (_noVoiceRecognitionModels.contains(i.id)) {
        return;
      }
    }
    if (!_mainController.settingsVoiceControl.value) return;
    if (_speechToText.isListening) return;

    //
    if (incrementTries) {
      _recognitionTries += 1;
    } else {
      _recognitionTries = 0;
    }


    if (!silent) {
      showSnackBarMessage(
        'Распознование голоса...',
        duration: const Duration(milliseconds: 1500),
      );
    }

    if (_audioPlayer.playing) await _audioPlayer.stop();

    var func = _voiceRecognitionForSelect;
    _speechToText.listen(
        onResult: func,
        localeId: 'ru_RU',
        pauseFor: const Duration(seconds: 5),
        listenMode: ListenMode.dictation);

    // _speechToText.errorListener = (data) {
    //   print(data);
    // };
  }

  Future<void> fakeVoiceRecognitionAndGoNext() async {
    _startVoiceRecognitionAfterAudioEnds = false;
    _audioPlayer.stop();


    if (_fakeVoiceRecognitionState) {
      showSnackBarMessage("Перехожу дальше...");
      await _audioPlayer.setAsset(_voiceRecStopAudioPath);
      await _audioPlayer.play();

      _fakeVoiceRecognitionState = false;
      _mainController.nextPage();
    } else {
      await _audioPlayer.setAsset(_voiceRecStartAudioPath);
      _audioPlayer.play();

      _fakeVoiceRecognitionState = true;
    }
  }

  void _voiceRecognitionForSelect(SpeechRecognitionResult result) async {
    if (!result.finalResult) {
      return;
    }

    // если юзер сказал назад или еще раз
    _recognizedWords = result.recognizedWords;
    showSnackBarMessage(
      'Распознал: $_recognizedWords',
      duration: const Duration(milliseconds: 800),
    );

    var select;
    for (var item in _mainController.currentPage) {
      if (item.typeTask == ActionTypeTask.select) {
        select = item;
        break;
      }
    }
    if (select == null) {
      return;
    }
    // algorithm that recognizes
    double maxCoef = 0;
    var answer = select.answerList.first;
    for (var item in select.answerList) {
      double coef = _recognizedWords
          .similarityTo(item.text.replaceAll(',', '').toLowerCase());
      if (coef > maxCoef) {
        maxCoef = coef;
        answer = item;
      }
    }

    showSnackBarMessage("${maxCoef}");
    if (maxCoef < 0.124) {
      print("pidroas");
      await _audioPlayer.stop();
      await _audioPlayer.setAsset(_voiceRecRetryAudioPath);
      await _audioPlayer.play();
      return;
    }

    _mainController.changeCurrentPage(answer.goTo);
    _recognizedWords = '';
  }
}
