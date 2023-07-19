import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:psychology_app/prefabs/default_text_style.dart';

import '../controllers/main_page_controller.dart';
import '../prefabs/colors.dart';
import '../services/local_storage_service.dart';

Future<void> showSettingsPopup(context) async {
  var mainController = Get.find<MainPageController>();
  saveSettings() => setSettings({
        'settingsVoiceControl': mainController.settingsVoiceControl.value,
        'settingsAutoplay': mainController.settingsAutoplay.value,
        'settingsSettingsHint': mainController.settingsSettingsHint.value,
      });

  mainController.settingsSettingsHint.value = false;
  saveSettings();

  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      backgroundColor: lightColor1,
      title: Center(
        child: Text(
          "Настройки",
          style: TextStyle(
            color: lightColor5,
            fontSize: 30.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      content: Obx(
        () => Table(
          columnWidths: const {
            0: FixedColumnWidth(120.0), // fixed to 100 width
            1: FixedColumnWidth(10.0), //fixed to 100 width
          },
          children: [
            TableRow(
              children: [
                const Text('Автовоспроизведение аудио'),
                Switch(
                  value: mainController.settingsAutoplay.value,
                  onChanged: (a) {
                    mainController.settingsAutoplay.value = a;
                    saveSettings();
                  },
                  activeColor: lightColor5,
                  activeTrackColor: lightColor4,
                  inactiveThumbColor: lightColor3,
                  inactiveTrackColor: lightColor4,
                ),
              ],
            ),
            TableRow(
              children: [
                const Text('Голосовое управление'),
                Switch(
                  value: mainController.settingsVoiceControl.value,
                  onChanged: (a) {
                    mainController.settingsVoiceControl.value = a;
                    saveSettings();
                  },
                  activeColor: lightColor5,
                  activeTrackColor: lightColor4,
                  inactiveThumbColor: lightColor3,
                  inactiveTrackColor: lightColor4,
                ),
              ],
            ),
            TableRow(
              children: [
                TextButton(
                  onPressed: () async{
                    await deleteEverything();
                    mainController.initialize();
                  },
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(Colors.white12),
                    backgroundColor: MaterialStateProperty.all(lightColor4),
                  ),
                  child: Text(
                    "Починить приложение?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(),
              ],
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: EdgeInsets.only(bottom: 15.sp),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context, 'Cancel');
          },
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all(Colors.white12),
            backgroundColor: MaterialStateProperty.all(lightColor4),
          ),
          child: Text(
            "Закрыть",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}
