import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
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

  // 매일 8시에 알림 예약
  static Future<void> scheduleDailyNotification() async {
    if (!_isInitialized) {
      print('알림 플러그인이 초기화되지 않았습니다.');
      return; // 초기화되지 않은 경우 알림을 표시하지 않음
    }

    // 시간대 설정 (local timezone)
    tzdata.initializeTimeZones();
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    final tz.TZDateTime scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      20, // 8 PM
      00,  // 0 minutes
    );

    // 만약 현재 시간이 8 PM을 지나면, 알림을 내일 8 PM으로 설정
    final tz.TZDateTime schedule = scheduledTime.isBefore(now)
        ? scheduledTime.add(Duration(days: 1))
        : scheduledTime;

    // 알림 세부 사항
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'channel id',
      'channel name',
      channelDescription: 'channel Description',
      importance: Importance.max,
      priority: Priority.max,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(badgeNumber: 1),
    );

    // 알림 예약
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // 알림 ID
      '어너러너', // 제목
      '잠깐 시간되시면 같이 달려보아요', // 내용
      schedule, // 예약 시간
      notificationDetails,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간에 반복
      androidScheduleMode: AndroidScheduleMode.exact, // 정확한 시간에 알림 예약
    );
  }


  // 알림 표시 (즉시)
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