import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reddit_bunshin/core/ui/themes.dart';
import 'package:reddit_bunshin/core/util/contract/app_contracts.dart';

class ThemeHelper {
  late Box<dynamic> _box;

  static ThemeHelper? _instance;

  static ThemeHelper get instance {
    _instance ??= ThemeHelper._private();

    return _instance!;
  }

  ThemeHelper._private() {
    _box = Hive.box<dynamic>(AppContracts.appBox);
  }

  ThemeData get fallbackTheme => AppThemes.darkTheme;

  ThemeData getTheme() {
    final savedTheme = _box.get(AppContracts.theme);

    if (savedTheme == Brightness.light.name) {
      return AppThemes.lightTheme;
    } else if (savedTheme == Brightness.dark.name) {
      return AppThemes.darkTheme;
    } else {
      return fallbackTheme;
    }
  }

  Future<void> saveTheme(ThemeData theme) {
    return _box.put(AppContracts.theme, theme.brightness.name);
  }
}
