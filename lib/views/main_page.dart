import 'dart:io';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:psychology_app/controllers/main_page_controller.dart';
import 'package:psychology_app/main.dart';
import 'package:psychology_app/prefabs/colors.dart';
import 'package:psychology_app/prefabs/default_text_style.dart';
import 'package:psychology_app/widgets/control_buttons.dart';
import 'package:psychology_app/widgets/select_list.dart';
import 'package:psychology_app/widgets/speaker_button.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/action_model.dart';
import '../widgets/loading_widget.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/text_block.dart';
import '../widgets/text_field.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final MainPageController _controller = Get.find<MainPageController>();
  late final _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );
  late final _animation = CurvedAnimation(
    parent: _animController,
    curve: Curves.easeIn,
  );

  @override
  void initState() {
    super.initState();
    if (!_controller.inited) {
      _controller.initialize();
    }
    if (_controller.settingsSettingsHint.value) {
      showSnackBarMessage(
        "Подсказка: потяните вверх чтобы открыть настройки",
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CustomRefreshIndicator(
        builder: MaterialIndicatorDelegate(
          backgroundColor: lightColor1,
          builder: (context, controller) {
            return Transform.rotate(
              angle: 180 * controller.value * 3.14 / 180,
              child: Icon(
                Icons.settings,
                color: lightColor5,
                size: 40,
              ),
            );
          },
        ),

        /// A function that is called when the user drags the refresh indicator.
        onRefresh: () => showSettingsPopup(context),

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.only(left: 20.sp, right: 20.sp),
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: double.infinity),
                    SizedBox(height: 40.sp),
                    ...getWidgetByAction(),
                    SizedBox(height: 40.sp),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getWidgetByAction() {
    List<Widget> ans = [];
    if (_controller.isLoadingFirstTime.value) {
      _animController.forward();
      return getWidgetsForDownloading(firstTime: true);
    }

    if (_controller.isLoading.value) {
      _animController.forward();
      ans = getWidgetsForDownloading();
    }

    // List<Widget> ans = getWidgetsForDownloading();

    bool addNavigationButtons = true;
    _controller.currentPageHaveSelectButtons = false;
    _controller.currentPageHaveFreeText = false;

    for (var item in _controller.currentPage) {
      switch (item.typeTask) {
        case ActionTypeTask.select:
          _controller.currentPageHaveSelectButtons = item.answerList.isNotEmpty;

          if (item.answerList.isNotEmpty) {
            ans.addAll(getWidgetsForSelectTask(item));
          }
          break;

        case ActionTypeTask.freeText:
          _controller.currentPageHaveFreeText = true;
          addNavigationButtons = false;
          ans.addAll(getWidgetsForFreeTextTask());
          break;

        case ActionTypeTask.appeal:
          ans.addAll(getWidgetsForAppealTask(item));
          break;

        case ActionTypeTask.speech:
          ans.addAll(getWidgetsForSpeechTask());
          break;
      }
    }
    if (addNavigationButtons) {
      ans.addAll([
        SizedBox(
          height: 20.sp,
        ),
        ControlButtons(
          onNextPressed: () async {
            _controller.nextPage();
          },
          nextButtonCondition: () => !_controller.currentPageHaveSelectButtons,
          onPreviousPressed: () => _controller.previousPage(),
        ),
      ]);
    }
    return ans;
  }

  List<Widget> getWidgetsForSelectTask(ActionModel item) {
    return [
      SizedBox(height: 20.sp),
      SelectButtonList(answerList: item.answerList)
    ];
  }

  List<Widget> getWidgetsForFreeTextTask() {
    var freeTextController = TextEditingController();
    return [
      SizedBox(height: 20.sp),
      MyTextField(
        hintText: "Enter your text here",
        controller: freeTextController,
        onNextPressed: () async {
          _controller.userFreeTextTaskAnswer(freeTextController.text);
          _controller.nextPage();
        },
      ),
      SizedBox(height: 20.sp),
      ControlButtons(
        onNextPressed: () async {
          _controller.userFreeTextTaskAnswer(freeTextController.text);
          _controller.nextPage();
        },
        onPreviousPressed: () => _controller.previousPage(),
      ),
    ];
  }

  List<Widget> getWidgetsForAppealTask(ActionModel item) {
    // Это нужно когда аппил идет подряд

    return [
      SpeakerButton(),
      SizedBox(height: 20.sp),
      TextBlock(text: item.question),
    ];
  }

  List<Widget> getWidgetsForSpeechTask() {
    return [];
  }

  List<Widget> getWidgetsForDownloading({bool firstTime = false}) {
    return [
      FadeTransition(
        opacity: _animation,
        child: LoadingWidget(
          text: firstTime
              ? "Загружаются необходимые файлы... Пожалуйста подождите"
              : "Обновление файлов... Пожалуйста подождите",
          value: _controller.loadingPercentage.value,
        ),
      ),
      SizedBox(
        height: 30.sp,
      )
    ];
  }
}
