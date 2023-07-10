import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:psychology_app/main.dart';

const HOST = "http://92.51.39.141/api";
var myHeaders = {
  "Content-type": "application/json",
};

class ApiService extends GetConnect {
  final _myHTTPClient = http.Client();

  @override
  Future<Response<T>> get<T>(
    url, {
    Map<String, String>? headers,
    String? contentType,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
  }) async {
    return await super.get(url, headers: myHeaders);
  }

  @override
  Future<Response<T>> post<T>(
    String? url,
    dynamic body, {
    String? contentType,
    Map<String, String>? headers,
    Map<String, dynamic>? query,
    Decoder<T>? decoder,
    Progress? uploadProgress,
  }) {
    return super.post(url, body, headers: myHeaders);
  }

  Future<dynamic> getActions() async {
    final res = await get('$HOST/actions');
    return res.body['message'];
  }

  Future<dynamic> checkActions(int version) async {
    final res = await post('$HOST/actions', {'version': version});

    if (res.statusCode == 202 || res.hasError) {
      // up to date
      return;
    }
    return 'not';
  }

  Future<dynamic> checkAudioMetaVersion(int version) async {
    final res = await post('$HOST/check_audio_meta', {'version': version});
    if (res.statusCode == 202 || res.hasError) {
      return;
    }
    return 'not';
  }

  Future<dynamic> getAudioList() async {
    final res = await get('$HOST/audio_list');
    return res.body['message'];
  }

  Future<dynamic> checkAudioList(Map body) async {
    final res = await post('$HOST/audio_list', body);
    return res.body['message'];
  }

  Future<List<int>?> getAudioFile(int audioId) async {
    try {
      final url = Uri.parse('$HOST/get_audio_file/$audioId');

      final response = await _myHTTPClient.get(url, headers: myHeaders);
      if (response.statusCode != 200) {
        throw Exception('Error downloading file: ${response.statusCode}');
      }
      final bytes = response.bodyBytes;
      return bytes;
    } catch (e) {
      showSnackBarMessage('Error while downloading audio [$audioId]: ${e.toString()}');
      return null;
    }
  }

  //AUTH
  Future<String> loginWithCredentials(String username, String password) async {
    // username = "Test";
    // password = "Test123pro!";
    final res =
        await post('$HOST/login', {'username': username, 'password': password});
    if (res.statusCode == 400) {
      return 'invalid';
    }
    myHeaders["Authorization"] = "Token ${res.body['token']}";
    return res.body['token'];
  }

  Future<String> isTokenValid(String t) async {
    final res = await post('$HOST/is_token_valid', {'token': t});

    if (res.body == null) {
      return 'no';
    }
    if (res.body['message'] == true) {
      myHeaders["Authorization"] = "Token $t";
    }
    print('Token valid: ${res.body['message'] == true ? "YES": 'NO'}');
    return res.body['message'] == true ? 'main' : 'login';
  }

  Future<String> sendUserFreeTextTaskAnswer(String taskId, String text) async{
    final body = {'task_id': taskId, 'text': text};
    final res = await post('$HOST/create_user_free_text_task', body);
    if (res.hasError){
      return 'error.';
    }
    if (res.body['message'] == true){
      return 'ok';
    }
    return res.body['message'];

  }
}

//TODO:  siri control

