import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceHelper{
  static Future<Map<String, dynamic>> getBatteryInfo() async{
    var battery = Battery();
    var batteryLevel = await battery.batteryLevel;

    var isInBatterySaverMode = await battery.isInBatterySaveMode;

    return{
      'batteryLevel': batteryLevel,
      'isInBatterySaverMode': isInBatterySaverMode
    };
  }
  static Future<Map<String, dynamic>> getDeviceInfo() async{
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    final allInfo = deviceInfo.data;
    return allInfo;
  }
}