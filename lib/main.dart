import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:psychology_app/prefabs/colors.dart';
import 'package:psychology_app/prefabs/default_text_style.dart';
import 'package:psychology_app/services/api_service.dart';
import 'package:psychology_app/views/login_page.dart';
import 'package:psychology_app/views/splash_screen_page.dart';

import 'controllers/main_page_controller.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  Get.put(ApiService());
  Get.put(MainPageController());

  await ScreenUtil.ensureScreenSize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Робот Психолог',
          // You can use the library anywhere in the app even in theme
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: Typography.englishLike2018.apply(
                fontSizeFactor: 1.sp,
                bodyColor: lightColor5,
                displayColor: lightColor5),
            scaffoldBackgroundColor: lightColor4,
            primaryColorLight: const Color.fromRGBO(246, 246, 246, 1),
            primaryColorDark: const Color.fromRGBO(21, 21, 21, 1.0),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromRGBO(21, 21, 21, 1.0),
            ),
          ),
          home: Builder(builder: (BuildContext  context) {
            Get.put<ScaffoldMessengerState>(ScaffoldMessenger.of(context));
            return const SplashScreen();
          }),
        );
      },
    );
  }
}



Future<void> showSnackBarMessage(String text, {Duration? duration}) async {
  duration = duration ?? const Duration(seconds: 2);
  Get.showSnackbar(
    GetSnackBar(
      messageText: Text(
        text,
        maxLines: 4,
        style: TextStyle(
          color: lightColor5,
          fontSize: 19.sp,
        ),
      ),
      backgroundColor: lightColor1,
      padding: EdgeInsets.all(10.sp),
      borderRadius: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      duration: duration,
    )
  );
}
