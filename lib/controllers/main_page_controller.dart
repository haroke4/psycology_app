import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:psychology_app/main.dart';
import '../models/action_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class MainPageController extends GetxController {
  var isLoading = false.obs;
  var isSending = false.obs;
  var loadingPercentage = 0.0.obs;
  var actionMap = <String, ActionModel>{}.obs;
  var historyOfActions = <String>[].obs;
  var currentAction = ActionModel(
          id: "0",
          typeTask: ActionTypeTask.select,
          nextId: "0",
          answerList: [],
          question: "0")
      .obs;

  final _apiService = Get.find<ApiService>();

  Future<void> _setActionList(data) async {
    actionMap.clear();
    for (var item in data) {
      actionMap.addAll({item['id'].toString(): ActionModel.fromJson(item)});
    }
    currentAction.value = actionMap[actionMap.keys.toList().first]!;
  }

  Future<void> fetchData() async {
    fetchActionList();
    fetchAudio();
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

    // Checking version
    var response = await _apiService.checkActions(localData['version']);
    if (response == null) { // we are up to date
      return;
    }

    // Getting new version from net and setting it up
    downloadAndSetActionList();
  }

  Future<void> downloadAndSetActionList() async {
    var fromNet = await _apiService.getActions();
    setLocalActionList(fromNet);
    _setActionList(fromNet['actions']);
  }

  Future<void> fetchAudio() async {
    var localAudioData = await getLocalAudioData();
    if (localAudioData == null) {
      // First time
      downloadAudioFiles(await downloadAudioList());
      return;
    }

    // Checking version
    var response = await _apiService
        .checkAudioMetaVersion(localAudioData['audio_meta_version']);
    if (response == null){ // Up to date
      return;
    }

    // Downloading list of audio's that need to be updated
    Map<String, int> body = {};
    for (var item in localAudioData['data']){
      body[item['id'].toString()] = item['version'];
    }

    response = await _apiService.checkAudioList(body);
    downloadAudioList();
    downloadAudioFiles(response);

  }



  Future<dynamic> downloadAudioList() async {
    var audioDataFromNet = await _apiService.getAudioList();
    await setLocalAudioData(audioDataFromNet);
    return audioDataFromNet['data'];
  }

  Future<void> downloadAudioFiles(data) async{
    // data = [{}, {}]
    isLoading.value = true;
    int length = data.length;

    for (int i = 0; i < length; i++) {
      loadingPercentage.value = i / length;

      final item = data[i];
      var bytes = await _apiService.getAudioFile(item['id']);
      saveAudioToLocal(item['name'], bytes!);
    }

    isLoading.value = false;

  }

  // Interactive

  void changeCurrentAction(String id_) {
    if (actionMap[id_] == null) return;

    historyOfActions.add(currentAction.value.id);
    currentAction.value = actionMap[id_]!;
  }

  void nextAction() {
    var next = actionMap[currentAction.value.nextId];

    if (next != null) {
      historyOfActions.add(currentAction.value.id);
      currentAction.value = next;
    }
  }

  void previousAction() {
    if (historyOfActions.isEmpty) return;
    var prevId = historyOfActions.last;
    historyOfActions.removeLast();
    currentAction.value = actionMap[prevId]!;
  }

  String getCurrentActionAudioPath(){
    return getActionAudioFilePath(currentAction.value);
  }

  Future<String> userFreeTextTaskAnswer(String text) async{
    isSending.value = true;
    final taskId = currentAction.value.id;
    final response = await _apiService.sendUserFreeTextTaskAnswer(taskId, text);
    isSending.value = false;
    if (response){
      return 'Отправлено';
    }
    return 'Something went wrong try again later';

  }
}
