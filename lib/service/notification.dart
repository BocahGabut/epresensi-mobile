import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  Future<void> initialize() async {
    await AwesomeNotifications().initialize(
        null, //'resource://drawable/res_app_icon',//
        [
          NotificationChannel(
              channelKey: 'notifications',
              channelName: 'Alerts',
              channelDescription: 'Notification tests as alerts',
              playSound: true,
              onlyAlertOnce: true,
              groupAlertBehavior: GroupAlertBehavior.Children,
              importance: NotificationImportance.High,
              defaultPrivacy: NotificationPrivacy.Private,
              defaultColor: Colors.deepPurple,
              ledColor: Colors.deepPurple)
        ],
        debug: true);

    await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  Future<void> showSimpleNotification(RemoteMessage message) async {
    String? bigPictureUrl = message.data['bigPicture'];

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch % 0xFFFFFFFF,
        channelKey: 'notifications',
        title: message.notification!.title,
        body: message.notification!.body,
        bigPicture: bigPictureUrl,
        notificationLayout: NotificationLayout.BigPicture,
      ),
    );
  }
}
