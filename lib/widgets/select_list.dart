import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:psychology_app/controllers/main_page_controller.dart';
import '../models/action_model.dart';
import '../prefabs/colors.dart';
import '../prefabs/default_text_style.dart';

class SelectButtonList extends StatelessWidget {
  final List<AnswerModel> answerList;

  const SelectButtonList({Key? key, required this.answerList})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: answerList.length,
      separatorBuilder: (BuildContext context, int index) {
        if (index != answerList.length) {
          return SizedBox(height: 10.sp);
        }
        return const SizedBox();
      },
      itemBuilder: (context, index) {
        final item = answerList[index];
        return _SelectButton(
          buttonID: index + 1,
          text: item.text,
          nextActionId: item.goTo,
        );
      },
    );
  }
}

class _SelectButton extends StatelessWidget {
  final int buttonID;
  final String text;
  final String nextActionId;

  _SelectButton({
    Key? key,
    required this.buttonID,
    required this.text,
    required this.nextActionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        var controller = Get.find<MainPageController>();
        controller.changeCurrentPage(nextActionId);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: lightColor2,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.sp, 12.sp, 20.sp, 12.sp),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: IntrinsicWidth(
            child: Text(
              text,
              style: defaultTextStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
