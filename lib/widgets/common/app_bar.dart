import 'package:flutter/material.dart';
import 'package:barber_app/utils/colors.dart';

AppBar buildAppBar(
  String title, {
  Color? backgroundColor,
  Color? foregroundColor,
}) {
  return AppBar(
    title: Text(title),
    backgroundColor: backgroundColor ?? AppColors.primaryOrange,
    foregroundColor: foregroundColor ?? AppColors.secondaryWhite,
  );
}
