import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/action_model.dart';

Directory? thisAppDirectory;

Future<void> createFile(String filename, String data) async {
  thisAppDirectory ??= await getApplicationDocumentsDirectory();
  final file = File('${thisAppDirectory?.path}/$filename');
  await file.writeAsString(data);
}

Future<dynamic> readFile(filename) async {
  try {
    thisAppDirectory ??= await getApplicationDocumentsDirectory();
    final file = File('${thisAppDirectory?.path}/$filename');
    return await file.readAsString();
  } catch (e) {
    return null;
  }
}

Future<bool> _deleteFile(filename) async{
  try {
    thisAppDirectory ??= await getApplicationDocumentsDirectory();
    final file = File('${thisAppDirectory?.path}/$filename');
    await file.delete(recursive: true);
    return true;
  } catch (e) {
    return false;
  }
}

Future<Map?> getSaving() async{
  var a = await readFile('saved.txt');
  if (a == null){
    return null;
  }
  return jsonDecode(a);

  return null;
}

Future<void> setSaving(String id, List history) async{
  await createFile('saved.txt', jsonEncode({'curr': id, 'history': history}));
}

Future<bool> isThisUsersFirstTimeUsingApp() async{
  final t = await readFile('token.txt');
  final d = await readFile('data.json');
  if (d == null || t == null ){
    return true;
  }
  return false;
}

Future<void> setAuthToken(String token) async {
  await createFile('token.txt', token);
}

Future<String> getAuthToken() async {
  final t = await readFile('token.txt');
  if (t == null) return '';
  return t.toString();
}

Future<void> setLocalActionList(data) async{
  await createFile('data.json', jsonEncode(data));
}

Future<Map<String, dynamic>?> getLocalActionsList() async{
  final t = await readFile('data.json');
  if (t == null) return null;
  final ans = jsonDecode(t);
  return ans;
}


Future<Map<String, dynamic>?> getLocalAudioData() async{
  final t = await readFile('audio_data.json');
  if(t == null) return null;
  return jsonDecode(t);
}

Future<void> setLocalAudioData(dataFromNet) async{
  await createFile('audio_data.json', jsonEncode(dataFromNet));
}

Future<void> saveAudioToLocal(filename, List<int> bytes) async{
  final directory = await getApplicationDocumentsDirectory();
  final audioDirectory = Directory('${directory.path}/audio');
  if(!await audioDirectory.exists()){
    await audioDirectory.create();
  }
  final file = File('${directory.path}/audio/$filename');
  await file.writeAsBytes(bytes);
}

String getActionAudioFilePath(ActionModel action){
  return '${thisAppDirectory?.path}/audio/${action.id}.m4a';
}

Future<Map<String, dynamic>?> getSettings() async{
  var a = await readFile('settings.json');
  if (a == null){
    return null;
  }

  return jsonDecode(a);
}

Future<void> setSettings(Map<String, dynamic> data) async{
  createFile('settings.json', jsonEncode(data));
}

Future<void> deleteEverything() async{
  for (var name in ['settings.json', 'audio_data.json', 'data.json', 'saved.txt']){
    await _deleteFile(name);
  }
  await Directory('${thisAppDirectory?.path}/audio').delete(recursive: true);
}