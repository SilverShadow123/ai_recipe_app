// ignore_for_file: unused_import

import 'package:ai_recipe_app/core/theme/app_theme.dart';
import 'package:ai_recipe_app/core/utils/device_helper.dart';
import 'package:ai_recipe_app/features/recipe/presentation/bloc/theme_settings/theme_settings_cubit.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void setFontFamilyCall(BuildContext context, FunctionCall functionCall){
  var fontFamily = functionCall.args['fontFamily']! as String;

  if(context.mounted){
    context.read<ThemeSettingsCubit>().setFontFamily(fontFamily);
  }
  return;

}

void setFontSizeFactorCall(BuildContext context, FunctionCall functionCall){
  var fontSizeFactor = functionCall.args['fontSizeFactor']! as num;

  if(context.mounted){
    context.read<ThemeSettingsCubit>().setFontSizeFactor(fontSizeFactor.toDouble());
  }
  return;
}

void setAppColorCall(BuildContext context, FunctionCall functionCall){
  int red = functionCall.args['red']! as int;
  int green = functionCall.args['green']! as int;
  int blue = functionCall.args['blue']! as int;

  Color newSeedColor = Color.fromRGBO(red, green, blue, 1);

  if(context.mounted){
    context.read<ThemeSettingsCubit>().setAppColor(newSeedColor);
  }
  return;
}

Future<String> getDeviceInfoCall() async{
  var deviceInfo = await DeviceHelper.getDeviceInfo();
  return 'Device Info: ${deviceInfo.toString()}';
}

Future<String> getBatteryInfoCall() async{
  var batteryInfo = await DeviceHelper.getBatteryInfo();
  return 'Battery Info: ${batteryInfo.toString()}';
}