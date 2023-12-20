import 'package:flutter/material.dart';
import 'package:reddit_bunshin/core/ui/themes.dart';
import 'package:reddit_bunshin/core/util/helper/theme_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeController extends StateNotifier<ThemeData> {
  static final provider = StateNotifierProvider<ThemeController, ThemeData>(
    (ref) => ThemeController(),
  );

  ThemeController() : super(ThemeHelper.instance.getTheme());

  void toggleTheme() {
    final savedTheme = ThemeHelper.instance.getTheme();

    if (savedTheme.brightness == Brightness.light) {
      state = AppThemes.darkTheme;
    } else {
      state = AppThemes.lightTheme;
    }

    ThemeHelper.instance.saveTheme(state);
  }
}
