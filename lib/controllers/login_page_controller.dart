import 'package:get/get.dart';
import 'package:psychology_app/services/api_service.dart';
import 'package:psychology_app/services/local_storage_service.dart';

class LoginController extends GetxController {
  var isLoggingIn = false.obs;
  var apiService = Get.find<ApiService>();

  Future<String> loginWithCredentials(String username, String password) async{

    if (isLoggingIn.isTrue){
      return "wait";
    }

    isLoggingIn.toggle();

    var r = await apiService.loginWithCredentials(username, password);
    await Future.delayed(Duration(seconds: 2)); // imitating server delay

    isLoggingIn.toggle();

    if (r == 'invalid') {
      return "invalid";
    }
    setAuthToken(r);
    return 'ok';
    // Get.to();
  }

}
