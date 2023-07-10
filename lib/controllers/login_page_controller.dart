import 'package:get/get.dart';
import 'package:psychology_app/main.dart';
import 'package:psychology_app/services/api_service.dart';
import 'package:psychology_app/services/local_storage_service.dart';

import '../views/main_page.dart';
import 'main_page_controller.dart';

class LoginController extends GetxController {
  var isLoggingIn = false.obs;
  var apiService = Get.find<ApiService>();

  Future<void> loginWithCredentials(String username, String password) async {
    if (isLoggingIn.value == true){
      return;
    }

    isLoggingIn.value = true;

    var r = await apiService.loginWithCredentials(username, password);
    var ans = 'ok';
    if (r == 'invalid') {
      showSnackBarMessage("Invalid username or password");
      return;
    }
    setAuthToken(r);
    showSnackBarMessage("Login successful");
    final controller = Get.find<MainPageController>();
    await controller.initialize();

    isLoggingIn.value = true;

    Get.offAll(
      const MainPage(),
      transition: Transition.cupertinoDialog,
      duration: const Duration(seconds: 1),
    );
  }
}
