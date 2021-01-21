
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class Umeng {
  static const MethodChannel _channel =
      const MethodChannel('kaige.com/umeng_analytics');

  static Future<bool> init({
    @required String androidKey,
    @required String iosKey,
    String channel,
    bool onlineParamEnabled = false,
    bool logEnabled = false,
    bool encryptEnabled = false,
    int sessionContinueMillis = 30000,
    bool processEventEnabled = true,
    String pageCollectMode = "AUTO",
  }) async {
    Map<String, dynamic> map = {
      'androidKey': androidKey,
      'iosKey': iosKey,
      'channel': channel,
      'onlineParamEnabled': onlineParamEnabled,
      'logEnabled': logEnabled,
      'encryptEnabled': encryptEnabled,
      'sessionContinueMillis': sessionContinueMillis,
      'processEventEnabled': processEventEnabled,
      'pageCollectMode': pageCollectMode,
    };
    return _channel.invokeMethod<bool>('init', map);
  }
  static Future<bool> pageStart(String widget) async{
    Map<String, dynamic> map = {
      'widget': widget,
    };
    return _channel.invokeMethod<bool>('pageStart', map);
  }
  static Future<bool> pageEnd(String widget) async{
    Map<String, dynamic> map = {
      'widget': widget,
    };
    return _channel.invokeMethod<bool>('pageEnd', map);
  }
  static Future<bool> onEvent(String eventId, Map<String,dynamic> properties){
    Map<String, dynamic> map = {
      'eventId': eventId,
      'properties': properties,
    };
    return _channel.invokeMethod<bool>('onEvent',map);
  }
  static Future<bool> onProfileSignIn(String id,{String provider = ""}){
    Map<String, dynamic> map = {
      'id': id,
      'provider': provider,
    };
    return _channel.invokeMethod<bool>('onProfileSignIn',map);
  }
  static Future<bool> onProfileSignOff(){
    return _channel.invokeMethod<bool>('onProfileSignOff');
  }
  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
  static Future<String> getOnlineParam(String key){
    Map<String, dynamic> map = {
      'key': key,
    };
    return _channel.invokeMethod<String>('getOnlineParam',map);
  }
}
