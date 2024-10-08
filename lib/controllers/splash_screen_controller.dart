import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:psychology_app/services/api_service.dart';
import 'package:psychology_app/services/local_storage_service.dart';
import 'package:psychology_app/views/login_page.dart';
import 'package:psychology_app/views/main_page.dart';

import 'main_page_controller.dart';

enum SplashScreenStateValues{
  ok,
  noConnection,
  wait,
}

class SplashScreenController extends GetxController {
  var currentState = SplashScreenStateValues.wait.obs;
  Rx<Widget> nextPage = Rx<Widget>(LoginPage());
  final _apiService = Get.find<ApiService>();

  Future<void> checkIfTokenValid() async{
    var t = await getAuthToken();
    var r = await _apiService.isTokenValid(t);

    switch(r){
      case 'no': {
        currentState.value = SplashScreenStateValues.noConnection;

      } break;
      case 'login': {
        nextPage.value = LoginPage();
        currentState.value = SplashScreenStateValues.ok;
      } break;
      case 'main': {
        nextPage.value = MainPage();
        currentState.value = SplashScreenStateValues.ok;
        final controller = Get.find<MainPageController>();
        await controller.initialize();

      } break;
      default: {} break;
    }

  }
}
