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

import '../models/action_model.dart';
import '../widgets/loading_widget.dart';
import '../widgets/text_block.dart';
import '../widgets/text_field.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  final MainPageController _controller = Get.put(MainPageController());
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
    _controller.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
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
    );
  }

  List<Widget> getWidgetByAction() {
    List<Widget> ans = [];
    if (_controller.isLoadingFirstTime.value) {
      return getWidgetsForDownloading(firstTime: true);
    }

    if (_controller.isLoading.value) {
      _animController.forward();
      ans = getWidgetsForDownloading();
    }
    // List<Widget> ans = getWidgetsForDownloading();

    switch (_controller.currentAction.value.typeTask) {
      case ActionTypeTask.select:
        return ans + getWidgetsForSelectTask();
      case ActionTypeTask.freeText:
        return ans + getWidgetsForFreeTextTask();
      case ActionTypeTask.appeal:
        return ans + getWidgetsForAppealTask();
      case ActionTypeTask.speech:
        return ans + getWidgetsForSpeechTask();
    }
  }

  List<Widget> getWidgetsForSelectTask() {
    if (_controller.currentAction.value.answerList.isEmpty) {
      return [
        ControlButtons(
          onNextPressed: () => _controller.nextAction(),
          onPreviousPressed: () => _controller.previousAction(),
        )
      ];
    }
    return [
      SelectButtonList(answerList: _controller.currentAction.value.answerList),
    ];
  }

  List<Widget> getWidgetsForFreeTextTask() {
    var textController = TextEditingController();
    return [
      MyTextField(
        hintText: "Enter your text here",
        controller: textController,
      ),
      SizedBox(height: 20.sp),
      ControlButtons(
        onNextPressed: () async {
          _controller.nextAction();
          showSnackBarMessage(
              await _controller.userFreeTextTaskAnswer(textController.text));
        },
        onPreviousPressed: () => _controller.previousAction(),
      ),
    ];
  }

  List<Widget> getWidgetsForAppealTask() {

    // Это нужно когда аппил идет подряд
    final GlobalKey<SpeakerButtonState> k = GlobalKey();
    var t = SpeakerButton(
        key: k, filePath: _controller.getCurrentActionAudioPath());
    return [
      t,
      SizedBox(height: 20.sp),
      TextBlock(text: _controller.currentAction.value.question),
      SizedBox(height: 20.sp),
      ControlButtons(
        onNextPressed: () {
          _controller.nextAction();
          k.currentState!.stopAndPlayNext();

        },
        onPreviousPressed: () => _controller.previousAction(),
      ),
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
