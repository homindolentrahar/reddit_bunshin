import 'package:flutter/material.dart';

abstract class AppColors {
  static const blackColor = Color.fromRGBO(1, 1, 1, 1); // primary color
  static const greyColor = Color.fromRGBO(26, 39, 45, 1); // secondary color
  static const drawerColor = Color.fromRGBO(18, 18, 18, 1);
  static const whiteColor = Colors.white;
  static var redColor = Colors.red.shade500;
  static var blueColor = Colors.blue.shade300;
}

abstract class AppThemes {
  static final darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: AppColors.blackColor,
    primaryColorDark: Colors.blue,
    primaryColorLight: Colors.blue,
    cardColor: AppColors.greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.blackColor,
      iconTheme: IconThemeData(
        color: AppColors.whiteColor,
      ),
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.drawerColor,
    ),
    primaryColor: AppColors.redColor,
    colorScheme: const ColorScheme.dark(
      background: AppColors.drawerColor,
      primary: Colors.blue,
      onPrimary: Colors.white,
    ),
  );

  static final lightTheme = ThemeData.light(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: AppColors.whiteColor,
    primaryColorLight: Colors.blue,
    primaryColorDark: Colors.blue,
    cardColor: AppColors.greyColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.whiteColor,
      elevation: 0,
      iconTheme: IconThemeData(
        color: AppColors.blackColor,
      ),
      titleTextStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.whiteColor,
    ),
    primaryColor: AppColors.redColor,
    colorScheme: const ColorScheme.light(
      background: AppColors.whiteColor,
      primary: Colors.blue,
      onPrimary: Colors.white,
    ),
  );
}
