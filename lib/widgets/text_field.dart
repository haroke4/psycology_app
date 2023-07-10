import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/main_page_controller.dart';
import '../prefabs/colors.dart';
import '../prefabs/default_text_style.dart';

class MyTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final Function onNextPressed;

  const MyTextField({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.onNextPressed,
  }) : super(key: key);

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      maxLines: 6,
      maxLength: 99999,
      style: defaultTextStyle,
      textInputAction: TextInputAction.go,
      onSubmitted: (value) {
        widget.onNextPressed();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      decoration: InputDecoration(
        counterText: '',
        fillColor: lightColor2,
        filled: true,
        hintText: widget.hintText,
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                style: BorderStyle.solid, color: lightColor2, width: 2.sp),
            borderRadius: BorderRadius.circular(20)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                style: BorderStyle.solid, color: lightColor1, width: 2.sp),
            borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}
