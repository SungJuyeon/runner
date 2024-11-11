import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';

class PushNotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false; // 초기화 상태 추적 변수

  // 로컬 알림 초기화
  static Future<void> init() async {
    if (_isInitialized) return; // 이미 초기화가 완료되었다면 초기화하지 않음

    AndroidInitializationSettings androidInitializationSettings =
    const AndroidInitializationSettings('mipmap/ic_launcher');

    DarwinInitializationSettings iosInitializationSettings =
    const DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    // 초기화 완료 후 상태 변경
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    _isInitialized = true; // 초기화 완료
  }

  // 알림 표시
  static Future<void> showNotification() async {
    if (!_isInitialized) {
      print('알림 플러그인이 초기화되지 않았습니다.');
      return; // 초기화되지 않은 경우 알림을 표시하지 않음
    }

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails('channel id', 'channel name',
        channelDescription: 'channel Description',
        importance: Importance.max,
        priority: Priority.max,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(badgeNumber: 1),
    );

    await flutterLocalNotificationsPlugin.show(
      0, '어너러너', '잠깐 시간되시면 같이 달려보아요', notificationDetails,
    );
  }
}

