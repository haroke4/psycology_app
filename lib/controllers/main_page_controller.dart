import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:psychology_app/controllers/audio_and_voice_rec_controller.dart';
import 'package:psychology_app/main.dart';

import '../models/action_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class MainPageController extends GetxController {
  // String is start id of the appeal action; dynamic because from it serializes from json
  var historyOfActions = <dynamic>[].obs;
  var currentPage = <ActionModel>[].obs;
  var actionMap = <String, ActionModel>{}.obs;
  var currentPageHaveSelectButtons = false;

  // Controller statuses
  var isLoadingFirstTime = false.obs;
  var isLoading = false.obs;
  var loadingPercentage = 0.0.obs;

  // Required for UI and stuff
  var inited = false;

  // Settings
  var settingsAutoplay = true.obs;
  var settingsVoiceControl = true.obs;
  var settingsSettingsHint = true.obs;
  var settingsSaveProgress = false.obs;

  //
  final _audioAndVoiceRecController = AudioAndVoiceRecController();

  AudioPlayer get getAudioPlayer => _audioAndVoiceRecController.getAudioPlayer;
  final _apiService = Get.find<ApiService>();

  Future<void> initialize() async {
    // settings
    var appSettings = await getSettings();
    if (appSettings != null) {
      settingsAutoplay.value = appSettings['settingsAutoplay'] ?? true;
      settingsVoiceControl.value = appSettings['settingsVoiceControl'] ?? true;
      settingsSettingsHint.value = appSettings['settingsSettingsHint'] ?? true;
      settingsSaveProgress.value = appSettings['settingsSaveProgress'] ?? false;
    }

    // voice recognition
    _audioAndVoiceRecController.initialize(this);

    await fetchActionList();
    await fetchAudio();
    await fetchNoVoiceRecognitionModels(); // no await because it does not so matter

    if (settingsSaveProgress.value) {
      var a = await getSaving();
      currentPage.clear();
      if (a != null && a['curr'] != '') {
        var b = actionMap[a['curr']];
        if (b != null) _addActionToPage(a['curr']);
        if (a['history'] != null) {
          historyOfActions.value = a['history'];
        }
      } else if (currentPage.isEmpty) {
        // APP OPENED FOR FIRST TIME
        _addActionToPage(actionMap[actionMap.keys.toList().first]!.id);
      }
      _audioAndVoiceRecController.playAppealActionAudio();
    } else if (currentPage.isEmpty) {
      _addActionToPage(actionMap[actionMap.keys.toList().first]!.id);
      _audioAndVoiceRecController.playAppealActionAudio();
    }

    inited = true;
  }

  Future<void> _setActionList(data) async {
    actionMap.clear();
    for (var item in data) {
      try {
        actionMap.addAll({item['id'].toString(): ActionModel.fromJson(item)});
      } catch (e) {
        print('ERROR ON ${item['id']} ${item['type_task']}');
      }
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
      await downloadAudioListAndAudioFiles();
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

  Future<void> downloadAudioListAndAudioFiles() async {
    isLoadingFirstTime.value = true;
    var audioDataFromNet = await _apiService.getAudioList();
    await setLocalAudioData(audioDataFromNet);
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
      if (bytes == null) {
        continue;
      }
      saveAudioToLocal(item['name'], bytes);
    }

    isLoading.value = false;
  }

  Future<void> fetchNoVoiceRecognitionModels() async {
    var localData = await getLocalNoVoiceRecognitionModels();
    if (localData != null) {
      _audioAndVoiceRecController.setNoVoiceRecognitionModels(localData);
    }

    // downloading new version from net
    var bb = await _apiService.getNoVoiceRecognitionModels();
    _audioAndVoiceRecController.setNoVoiceRecognitionModels(bb);
    setLocalNoVoiceRecognitionModels(bb);
  }

  Future<String> userFreeTextTaskAnswer(text) async {
    if (text == '') return 'Вы ввели пустой текст';
    final response = await _apiService.sendUserFreeTextTaskAnswer('2_1', text);
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
    _audioAndVoiceRecController.stopVoiceRecognition();

    if (fromPrevious) {
      // если идем назад
      currentPage.clear();
      _addActionToPage(historyOfActions.last);
      id_ = historyOfActions.last;
      historyOfActions.removeLast();
    } else {
      historyOfActions.add(currentPage.first.id);
      currentPage.clear();
      _addActionToPage(id_);
    }

    setSaving(id_, historyOfActions);
    _audioAndVoiceRecController.playAppealActionAudio();
  }

  void _addActionToPage(String id_) {
    var curr = actionMap[id_];
    if(curr == null){
      showSnackBarMessage("ERROR AT: ${id_}");
      return;

    }
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
    var a = actionMap[id_];
    if (a == null) return;
    if (a.typeTask != ActionTypeTask.appeal) return;
    _everyStepActions(id_);
  }

  void nextPage() {
    var last = currentPage.last;
    if (last.nextId != '') {
      _everyStepActions(last.nextId);
    }
  }

  void previousPage() {
    if (historyOfActions.isEmpty) return;
    _everyStepActions('', fromPrevious: true);
  }

  String getCurrentActionAudioPath() {
    var action = currentPage.first;
    return getActionAudioFilePath(action);
  }

  void startVoiceRecognition({bool justListen = false}) async {
    await _audioAndVoiceRecController.stopVoiceRecognition();
    if (!currentPageHaveSelectButtons) {
      _audioAndVoiceRecController.fakeVoiceRecognitionAndGoNext();
      return;
    }
    _audioAndVoiceRecController.startVoiceRecognition();
  }
}
