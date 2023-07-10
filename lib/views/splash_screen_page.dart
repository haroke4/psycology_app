import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:psychology_app/controllers/splash_screen_controller.dart';
import 'package:psychology_app/prefabs/colors.dart';
import 'package:psychology_app/views/main_page.dart';

import '../controllers/main_page_controller.dart';
import '../services/local_storage_service.dart';
import '../widgets/retry_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final _pageController = SplashScreenController();
  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 2000),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();

    _animationController.addStatusListener(animationStatusListener);
    _animationController.forward(from: 0.0);

    asyncInitState(firstTime: true);
  }

  void animationStatusListener(status) async {
    if (status == AnimationStatus.completed) {
      switch (_pageController.currentState.value) {
        case SplashScreenStateValues.ok:
          {
            Get.offAll(() => _pageController.nextPage.value);
          }
          break;
        case SplashScreenStateValues.noConnection:
          {
            if (await isThisUsersFirstTimeUsingApp()) {
              // ignore: use_build_context_synchronously
              showRetryDialog(context, () {
                asyncInitState();
                _animationController.forward(from: 0.0);
              });
              return;
            }
            _animationController.forward(from: 0.0);
            final controller = Get.find<MainPageController>();
            await controller.initialize();
            Get.offAll(() => const MainPage());
          }
          break;
        case SplashScreenStateValues.wait:
          {
            _animationController.forward(from: 0.0);
          }
          break;
      }
    }
  }

  void asyncInitState({bool firstTime = false}) async {
    _pageController.checkIfTokenValid();
    // sharedPrefs.clear();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightColor4,
      body: Center(
        child: RotationTransition(
          turns: Tween(begin: 0.0, end: 1.0).animate(_animationController),
          child: const Icon(
            Icons.ac_unit_sharp,
            size: 200,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
