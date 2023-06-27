import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../prefabs/colors.dart';
import '../prefabs/default_text_style.dart';

class LoadingWidget extends StatelessWidget {
  final String text;
  final double value;

  const LoadingWidget({Key? key, required this.text, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 12.sp),
        decoration: BoxDecoration(
          color: lightColor2,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: lightColor5, //New
                blurRadius: 10,
                spreadRadius: 8,
                offset: const Offset(0, 10))
          ],
        ),
        child: Column(
          children: [
            Text(
              text,
              style: defaultTextStyle,
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20.sp,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.sp),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                child: LinearProgressIndicator(
                  minHeight: 20.sp,
                  color: lightColor5,
                  backgroundColor: lightColor4,
                  value: value,
                ),
              ),
            ),
          ],
        ));
  }
}
