import 'package:e_absensi/service/firebase_messaging_service.dart';
import 'package:e_absensi/utils/global.const.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class SendTokenFCM {
  static Future<void> refreshToken() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? token = await FirebaseMessagingService().getFCMToken();

    final String? accessToken = await secureStorage.read(key: 'access_token');
    if (accessToken != null) {
      final Map<String, String> data = {
        'token': token ?? '',
        'accessToken': accessToken,
      };

      await http.post(Uri.parse('${GlobalConst.urlApi}refresh-token-fcm'),
          body: data);
    }
  }
}
