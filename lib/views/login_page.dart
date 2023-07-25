import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:psychology_app/main.dart';
import 'package:psychology_app/prefabs/colors.dart';
import 'package:psychology_app/controllers/login_page_controller.dart';
import 'package:psychology_app/prefabs/default_text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:psychology_app/services/api_service.dart';
import 'package:psychology_app/views/main_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final _loginController = LoginController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightColor4,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10.sp,
              ),
              Center(
                child: Image.asset(
                  'assets/image.png',
                  width: 280.sp,
                  height: 280.sp,
                ),
              ),

              LoginTextField(
                hintText: "Логин",
                controller: _usernameController,
                obscure: false,
              ),
              SizedBox(
                height: 20.sp,
              ),
              LoginTextField(
                hintText: "Пароль",
                controller: _passwordController,
                obscure: true,
              ),
              SizedBox(
                height: 20.sp,
              ),
              Obx(() => getButton()),
              SizedBox(
                height: 50.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getButton() {
    return ElevatedButton(
      onPressed: () {
        FocusManager.instance.primaryFocus?.unfocus();
        _loginController.loginWithCredentials(
          _usernameController.value.text,
          _passwordController.value.text,
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: lightColor2,
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(40.sp, 12.sp, 40.sp, 12.sp),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _loginController.isLoggingIn.value
              ? CupertinoActivityIndicator(
                  color: lightColor4,
                  radius: 15.sp,
                )
              : Text(
                  "Войти",
                  style: defaultTextStyle,
                ),
        ),
      ),
    );
  }
}

class LoginTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final bool obscure;

  const LoginTextField({
    Key? key,
    required this.hintText,
    required this.controller,
    required this.obscure,
  }) : super(key: key);

  @override
  State<LoginTextField> createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 20.sp, right: 20.sp),
      child: TextField(
        controller: widget.controller,
        style: defaultTextStyle,
        obscureText: widget.obscure,
        decoration: InputDecoration(
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
      ),
    );
  }
}
