import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../prefabs/colors.dart';

void showRetryDialog(context, Function after) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Center(
        child: Text(
          "Ошибка",
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 30.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Text(
        "Нет подключения к серверу. Пожалуйста, убедитесь, что вы подключены к Интернету",
        style: TextStyle(
          color: Theme.of(context).primaryColorDark,
          fontSize: 22.sp,
        ),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: EdgeInsets.only(bottom: 15.sp),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'Cancel');
            after();
          },
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(Colors.white12),
            backgroundColor: MaterialStateProperty.all(lightColor4),
          ),
          child: Text(
            "Попробовать \nеще раз",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}