import 'dart:convert';

import 'package:e_absensi/service/firebase_messaging_service.dart';
import 'package:e_absensi/utils/device_info.dart';
import 'package:e_absensi/utils/global.const.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static Future<bool> login(String username, String password) async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();

    String? token = await FirebaseMessagingService().getFCMToken();
    Map<String, dynamic> deviceInfo = await getDeviceInfo();
    String ipAddress = await getIpAddress();

    final Map<String, String> data = {
      'username': username,
      'password': password,
      'token': token ?? '',
    };

    final http.Response response = await http.post(
        Uri.parse('${GlobalConst.urlApi}login-device'),
        body: data,
        headers: {'xplatform': jsonEncode(deviceInfo), 'ipAddress': ipAddress});

    Map<String, dynamic> responseData = jsonDecode(response.body);
    if (responseData['error'] == true) {
      return false;
    } else {
      await secureStorage.write(
          key: 'access_token', value: responseData['data']['token']);
      await secureStorage.write(key: 'isLogin', value: 'true');
      return true;
    }
  }

  static Future<bool> checkAuth(String token) async {
    final http.Response response = await http.post(
        Uri.parse('${GlobalConst.urlApi}check-device'),
        body: {'token': token});

    Map<String, dynamic> responseData = jsonDecode(response.body);
    if (responseData['error'] == true) {
      return false;
    } else {
      return true;
    }
  }
}
