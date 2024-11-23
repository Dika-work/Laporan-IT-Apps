import 'package:flutter/material.dart';
import 'package:laporan/utils/theme/app_colors.dart';
import 'package:laporan/utils/theme/appbar.dart';
import 'package:laporan/utils/theme/checkbox.dart';
import 'package:laporan/utils/theme/elevated_btn.dart';
import 'package:laporan/utils/theme/outline_btn.dart';
import 'package:laporan/utils/theme/text_field.dart';
import 'package:laporan/utils/theme/text_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Urbanist',
    disabledColor: AppColors.grey,
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    textTheme: CustomTextTheme.lightTextTheme,
    appBarTheme: CustomAppBarTheme.lightAppBarTheme,
    checkboxTheme: CustomCheckboxTheme.lightCheckboxTheme,
    scaffoldBackgroundColor: AppColors.primaryBackground,
    elevatedButtonTheme: CustomElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: CustomOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: CustomTextFormFieldTheme.lightInputDecorationTheme,
  );
}
