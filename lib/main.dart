import 'package:e_absensi/firebase_options.dart';
import 'package:e_absensi/service/notification.dart';
import 'package:e_absensi/service/send_token_fcm.dart';
import 'package:e_absensi/view/login_screen.dart';
import 'package:e_absensi/view/webview_screen.dart';
import 'package:e_absensi/view/welcome_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:geolocator/geolocator.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Got a message whilst in the foreground!');
  print('Message data: ${message.data}');

  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
    NotificationService().showSimpleNotification(message);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  await FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.onMessage.listen(_firebaseMessagingBackgroundHandler);

  const FlutterSecureStorage secureStorage = FlutterSecureStorage();
  await FlutterDownloader.initialize(debug: true, ignoreSsl: true);
  await SendTokenFCM.refreshToken();

  final notificationService = NotificationService();
  await notificationService.initialize();

  var status = await Permission.phone.status;
  if (status != PermissionStatus.granted) {
    var result = await Permission.phone.request();
    if (result != PermissionStatus.granted) {
      return;
    }
  }

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool showWelcomeScreen = prefs.getBool('welcomeScreen') ?? true;

  final String? accessToken = await secureStorage.read(key: 'access_token');
  final String? isLogin = await secureStorage.read(key: 'isLogin');

  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  await Permission.camera.request();

  if (accessToken != null && isLogin == 'true') {
    runApp(
        MyApp(accessToken: accessToken, showWelcomeScreen: showWelcomeScreen));
  } else {
    runApp(MyApp(showWelcomeScreen: showWelcomeScreen));
  }
}

class MyApp extends StatelessWidget {
  final bool showWelcomeScreen;
  final String? accessToken;
  const MyApp({super.key, required this.showWelcomeScreen, this.accessToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ePresensi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.light,
      home: accessToken != null
          ? WebViewApp(accessToken: accessToken!)
          : showWelcomeScreen
              ? const WelcomeScreen()
              : const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
