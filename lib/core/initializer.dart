import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reddit_bunshin/core/util/contract/app_contracts.dart';
import 'package:reddit_bunshin/firebase_options.dart';

class Initializer {
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.circle
      ..maskType = EasyLoadingMaskType.black
      ..loadingStyle = EasyLoadingStyle.light
      ..maskColor = Colors.black.withOpacity(0.5);

    await initHive();
  }

  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox<dynamic>(AppContracts.appBox);
  }
}
