import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final _firebaseMessaging = FirebaseMessaging.instance; 
  
  Future<String?> getFCMToken() async {
    try {
      await _firebaseMessaging.requestPermission();
      final fcmToken = await _firebaseMessaging.getToken();
      return fcmToken;
    } catch (e) {
      return null;
    }
  }

  static void configureFirebaseMessaging() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.body}');
      // Handle pesan yang diterima saat aplikasi berjalan
    });
  }
}
