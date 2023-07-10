import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:psychology_app/main.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import  'package:string_similarity/string_similarity.dart';

import '../models/action_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class MainPageController extends GetxController {
  var currentPageHaveSelectButtons = false;
  var freeTextController;

  var isLoadingFirstTime = false.obs;
  var isLoading = false.obs;
  var isSending = false.obs;
  var loadingPercentage = 0.0.obs;

  var actionMap = <String, ActionModel>{}.obs;
  // String is start id of the appeal action; dynamic because from it serializes from json
  var historyOfActions = <dynamic>[].obs;
  var currentPage = <ActionModel>[].obs;

  // Settings
  var settingsAutoplay = true.obs;
  var settingsVoiceControl = true.obs;
  var settingsSettingsHint = true.obs;

  //
  final _apiService = Get.find<ApiService>();
  final SpeechToText _speechToText = SpeechToText();

  Future<void> initialize() async {
    var appSettings = await getSettings();
    if (appSettings != null){
      settingsAutoplay.value = appSettings['settingsAutoplay'];
      settingsVoiceControl.value = appSettings['settingsVoiceControl'];
      settingsSettingsHint.value = appSettings['settingsSettingsHint'];
    }

    var speechToTextStatus = await _speechToText.initialize();
    if(!speechToTextStatus){
      showSnackBarMessage('Голосовое управление не поддерживается на этом устройстве');
    }

    await fetchActionList();
    await fetchAudio();

    var a = await getSaving();
    if (a != null && a['curr'] != '') {
      var b = actionMap[a['curr']];
      if (b != null) _addActionToPage(a['curr']);
      if (a['history'] != null) {
        historyOfActions.value = a['history'];
      }
    } else {
      // APP OPENED FOR FIRST TIME
      _addActionToPage(actionMap[actionMap.keys.toList().first]!.id);
    }
  }

  Future<void> _setActionList(data) async {
    actionMap.clear();
    for (var item in data) {
      actionMap.addAll({item['id'].toString(): ActionModel.fromJson(item)});
    }
  }

  Future<void> fetchActionList() async {
    var localData = await getLocalActionsList();

    if (localData == null) {
      // No local data
      downloadAndSetActionList();
      return;
    }

    // We have local data, setting action list
    _setActionList(localData['actions']);

    // Getting new version from net and setting it up | not await because we wanna show user our local data and then update
    downloadAndSetActionList(localDataVersion: localData['version']);
  }

  Future<void> downloadAndSetActionList({localDataVersion = ''}) async {
    // Checking version
    if (localDataVersion != '') {
      var response = await _apiService.checkActions(localDataVersion);
      if (response == null) {
        // we are up to date
        return;
      }
    }
    await showSnackBarMessage("Загружаются новые текстовые данные...");
    var fromNet = await _apiService.getActions();
    setLocalActionList(fromNet);
    _setActionList(fromNet['actions']);
    await showSnackBarMessage("Текстовые данные обновлены успешно!");
  }

  Future<void> fetchAudio() async {
    var localAudioData = await getLocalAudioData();
    if (localAudioData == null) {
      // First time
      await downloadAudioList();
      return;
    }

    // we have local data but we check it |  not await because we wanna show user our local data and then update
    checkLocalAudioFilesAndDownloadNew(localAudioData);
  }

  Future<void> checkLocalAudioFilesAndDownloadNew(localAudioData) async {
    var response = await _apiService
        .checkAudioMetaVersion(localAudioData['audio_meta_version']);
    if (response == null) {
      // Up to date
      return;
    }

    await showSnackBarMessage("Загружается новые аудио файлы...");

    // Downloading LIST of audio's that need to be updated
    Map<String, int> body = {};
    for (var item in localAudioData['data']) {
      body[item['id'].toString()] = item['version'];
    }

    // Downloading audio FILES
    response = await _apiService.checkAudioList(body);
    await downloadAudioFilesAndSave(response);

    // Download Audio DATA (not actual files)
    var audioDataFromNet = await _apiService.getAudioList();
    await setLocalAudioData(audioDataFromNet);

    await showSnackBarMessage("Аудио файлы обновлены успешно!");
  }

  Future<void> downloadAudioList({localAudioData}) async {
    if (localAudioData != null) {
      // we have local data but we check it
      // Checking version
    }

    var audioDataFromNet = await _apiService.getAudioList();
    await setLocalAudioData(audioDataFromNet);

    isLoadingFirstTime.value = true;
    await downloadAudioFilesAndSave(audioDataFromNet['data']);
    isLoadingFirstTime.value = false;
    await showSnackBarMessage("Аудио файлы обновлены успешно!");
  }

  Future<void> downloadAudioFilesAndSave(data) async {
    // data = [{}, {}]
    isLoading.value = true;
    int length = data.length;

    for (int i = 0; i < length; i++) {
      loadingPercentage.value = i / length;

      final item = data[i];
      var bytes = await _apiService.getAudioFile(item['id']);
      if (bytes == null){
        continue;
      }
      saveAudioToLocal(item['name'], bytes);
    }

    isLoading.value = false;
  }

  Future<String> userFreeTextTaskAnswer() async {
    isSending.value = true;
    final response = await _apiService.sendUserFreeTextTaskAnswer('2_1', freeTextController.text);
    isSending.value = false;
    switch (response) {
      case 'ok':
        return 'Отправлено';
      case 'no text':
        return 'Вы не ввели текст';
      default:
        return 'Что то пошло не так, повторите позже';
    }
  }

  // Interactive
  void _everyStepActions(String id_, {fromPrevious = false}) {
    if (fromPrevious) {
      currentPage.clear();
      _addActionToPage(historyOfActions.last);
      id_ = historyOfActions.last;
      historyOfActions.removeLast();

    } else {
      historyOfActions.add(currentPage.value.first.id);
      currentPage.clear();
      _addActionToPage(id_);
    }
    setSaving(id_, historyOfActions);
  }

  void _addActionToPage(String id_) {
    var curr = actionMap[id_]!;
    currentPage.add(curr);

    var temp = actionMap[actionMap[id_]!.nextId];
    if (temp == null) {
      return;
    }
    if (temp.typeTask != ActionTypeTask.appeal) {
      _addActionToPage(temp.id);
    }
  }

  void changeCurrentPage(String id_) {
    if (actionMap[id_] == null) return;
    _everyStepActions(id_);
  }

  void nextPage() {
    var last = currentPage.last;
    if (currentPage.last.nextId != '') {
      _everyStepActions(last.nextId);
    }
  }

  void previousPage() {
    if (historyOfActions.isEmpty) return;
    _everyStepActions('', fromPrevious: true);
  }

  String getCurrentActionAudioPath(action) {
    return getActionAudioFilePath(action);
  }

  // voice recognition
  void startVoiceRecognition({Function? handler}) async {
    if (!settingsVoiceControl.value) return;
    showSnackBarMessage('Распознование голоса...');
    var func = _voiceRecognitionResult;
    if (handler != null) func = (a) => handler(a);
    if (currentPageHaveSelectButtons) func = _voiceRecognitionForSelect;
    if (freeTextController != null) func = _voiceRecognitionForFreeText;
    _speechToText.listen(
      onResult: func,
      localeId: 'ru_RU',
      pauseFor: const Duration(seconds: 5),
    );
  }

  void _voiceRecognitionResult(SpeechRecognitionResult result) {
    if (!result.finalResult){
      return;
    }
    var words = result.recognizedWords;
    var next = [
      'Сделал',
      'Готово',
      'Дальше',
      'Далее',
      'Получилось',
      'Все',
      'Доделал',
      'Закончил'
    ];

    var back = ['Назад', 'Обратно'];
    var repeat = ['Еще раз', 'Перемотай', 'Заново', 'Ещё раз'];
    var recognitionResult = '';

    showSnackBarMessage('Распознал: $words');

    for (var item in next) {
      if (words.toLowerCase().contains(item.toLowerCase())) {
        recognitionResult = 'next';
      }
    }
    for (var item in back) {
      if (words.toLowerCase().contains(item.toLowerCase())) {
        recognitionResult = 'back';
      }
    }
    for (var item in repeat) {
      if (words.toLowerCase().contains(item.toLowerCase())) {
        recognitionResult = 'repeat';
      }
    }

    switch (recognitionResult) {
      case 'next':
        nextPage();
        break;
      case 'back':
        previousPage();
        break;
      case 'repeat':
        var a = currentPage.first.id;
        currentPage.clear();
        _addActionToPage(a);
        break;

      default:
        showSnackBarMessage('Нет действия для $words');
        break;
    }
  }

  void _voiceRecognitionForSelect(SpeechRecognitionResult result){
    if (!result.finalResult){
      return;
    }
    var select;
    for (var item in currentPage){
      if (item.typeTask == ActionTypeTask.select){
        select = item;
        break;
      }
    }
    if (select == null){
      return;
    }
    // algorithm that recognizes
    var words = result.recognizedWords;
    showSnackBarMessage('Распознал: $words');
    double maxCoef = 0;
    var answer = select.answerList.first;
    for (var item in select.answerList){
      double coef = words.similarityTo(item.text.replaceAll(',', '').toLowerCase());
      if (coef > maxCoef){
        maxCoef = coef;
        answer = item;
      }

    }
    changeCurrentPage(answer.goTo);
  }

  void _voiceRecognitionForFreeText(SpeechRecognitionResult result) async{
    freeTextController.text = result.recognizedWords;
    if (result.finalResult){
      freeTextController = null;
      userFreeTextTaskAnswer();
      nextPage();

    }
  }
}
