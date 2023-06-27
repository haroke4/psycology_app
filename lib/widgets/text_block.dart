import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../prefabs/colors.dart';
import '../prefabs/default_text_style.dart';
class TextBlock extends StatelessWidget {
  final String text;
  const TextBlock({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        color: lightColor2,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: defaultTextStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}
