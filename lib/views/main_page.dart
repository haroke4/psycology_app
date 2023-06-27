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
import '../widgets/text_block.dart';
import '../widgets/text_field.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final MainPageController _controller = Get.put(MainPageController());

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
    if (_controller.isLoading.value) {
      return getWidgetsForDownloading();
    }

    switch (_controller.currentAction.value.typeTask) {
      case ActionTypeTask.select:
        return getWidgetsForSelectTask();
      case ActionTypeTask.freeText:
        return getWidgetsForFreeTextTask();
      case ActionTypeTask.appeal:
        return getWidgetsForAppealTask();
      case ActionTypeTask.speech:
        return getWidgetsForSpeechTask();
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
          showSnackBarMessage(
              await _controller.userFreeTextTaskAnswer(textController.text));
          _controller.nextAction();
        },
        onPreviousPressed: () => _controller.previousAction(),
      ),
    ];
  }

  List<Widget> getWidgetsForAppealTask() {
    return [
      SpeakerButton(filePath: _controller.getCurrentActionAudioPath()),
      SizedBox(height: 20.sp),
      TextBlock(text: _controller.currentAction.value.question),
      SizedBox(height: 20.sp),
      ControlButtons(
        onNextPressed: () => _controller.nextAction(),
        onPreviousPressed: () => _controller.previousAction(),
      ),
    ];
  }

  List<Widget> getWidgetsForSpeechTask() {
    return [];
  }

  List<Widget> getWidgetsForDownloading() {
    return [
      const TextBlock(
          text: "Required audio files are downloading... Please wait"),
      SizedBox(height: 40.sp),
      LinearProgressIndicator(
        minHeight: 10.sp,
        color: lightColor5,
        backgroundColor: lightColor2,
        value: _controller.loadingPercentage.value,
      ),
    ];
  }
}
