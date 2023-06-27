import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../prefabs/colors.dart';

void showRetryDialog(context, Function after) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: Center(
        child: Text(
          "No internet",
          style: TextStyle(
            color: Theme.of(context).primaryColorDark,
            fontSize: 40.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Text(
        "No connection to the server. Please make sure that you are connected to the internet. The internet is required to load initial data.",
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
            "Retry",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.sp,
            ),
          ),
        ),
      ],
    ),
  );
}