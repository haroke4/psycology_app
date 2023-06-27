import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../main.dart';
import '../prefabs/colors.dart';

class ControlButtons extends StatelessWidget {
  final Function onNextPressed;
  final Function onPreviousPressed;
  final Function? nextButtonCondition;

  const ControlButtons({
    Key? key,
    required this.onNextPressed,
    required this.onPreviousPressed,
    this.nextButtonCondition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            onPreviousPressed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: lightColor2,
            disabledBackgroundColor: const Color.fromRGBO(197, 170, 170, 1.0),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(40.sp, 12.sp, 40.sp, 12.sp),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: IntrinsicWidth(
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: lightColor5,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.sp),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: lightColor5,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20.sp),
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: lightColor5,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 20.sp),
        ElevatedButton(
          onPressed: handleNextButtonCondition() ? () => onNextPressed() : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: lightColor2,
            disabledBackgroundColor: const Color.fromRGBO(197, 170, 170, 1.0),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(40.sp, 12.sp, 40.sp, 12.sp),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: IntrinsicWidth(
                child: Row(
                  children: [
                    Stack(
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          color: lightColor5,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10.sp),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: lightColor5,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 20.sp),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            color: lightColor5,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool handleNextButtonCondition() {
    if (nextButtonCondition == null){
      return true;
    }
    return nextButtonCondition!();
  }
}
