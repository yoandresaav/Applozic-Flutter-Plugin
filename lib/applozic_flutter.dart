import 'dart:async';

import 'package:flutter/services.dart';

class ApplozicFlutter {
  static const MethodChannel _channel = const MethodChannel('applozic_flutter');

  static Future<dynamic> login(dynamic user, String firebaseId) async {
    return await _channel.invokeMethod('login', user);
  }

  static Future<bool> isLoggedIn() async {
    return await _channel.invokeMethod('isLoggedIn');
  }

  static Future<dynamic> logout() async {
    return await _channel.invokeMethod('logout');
  }

  static Future<dynamic> launchChat() async {
    return await _channel.invokeMethod('launchChat');
  }

  static Future<dynamic> launchChatWithUser(dynamic userId) async {
    return await _channel.invokeMethod('launchChatWithUser', userId);
  }

  static Future<dynamic> launchChatWithGroupId(dynamic groupId) async {
    return await _channel.invokeMethod('launchChatWithGroupId', groupId);
  }

  static Future<dynamic> createGroup(dynamic groupInfo) async {
    return await _channel.invokeMethod('createGroup', groupInfo);
  }

  static Future<dynamic> addContacts(dynamic contactJson) async {
    return await _channel.invokeMethod('addContacts', contactJson);
  }

  static Future<dynamic> updateUserDetail(dynamic user) async {
    return await _channel.invokeMethod('updateUserDetail', user);
  }

  static Future<String> getLoggedInUserId() async {
    return await _channel.invokeMethod('getLoggedInUserId');
  }
}
