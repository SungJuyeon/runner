import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:async';

class PushNotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false; // 초기화 상태 추적 변수

  static Future<void> cancelScheduledNotification() async {
    await flutterLocalNotificationsPlugin.cancel(1);  // 알림 ID 1번 취소
  }

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

    // Timezone 초기화
    tz.initializeTimeZones();

    //const String timeZone = 'Asia/Seoul';
    //tz.setLocalLocation(tz.getLocation(timeZone));
    //print('Current Timezone: ${tz.local.name}');
  }

  // 알림 표시
  static Future<void> showNotification() async {
    if (!_isInitialized) {
      print('알림 플러그인이 초기화되지 않았습니다.');
      return;
    }

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
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      '어너러너',
      '잠깐 시간되시면 같이 달려보아요',
      notificationDetails,
    );
  }

  // 매일 특정 시간에 알림 스케줄링
  static Future<void> scheduleDailyNotification() async {
    if (!_isInitialized) {
      print('알림 플러그인이 초기화되지 않았습니다.');
      return;
    }

    // 현재 시간대 가져오기
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    // 오후 8시로 알림 시간 설정
    tz.TZDateTime scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      7, // 20:00 (8 PM)
      40,
      0,
    );
    print('Current Timezone: ${tz.local.name}');
    print('Now (local): $now');
    print('Scheduled Time (local): $scheduledTime');

    // 만약 현재 시간이 오후 8시 이후라면, 다음 날 오후 8시로 설정
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      'daily_channel_id',
      'daily_channel_name',
      channelDescription: 'daily_channel_description',
      importance: Importance.max,
      priority: Priority.max,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    // 매일 반복 알림 스케줄링
    await flutterLocalNotificationsPlugin.zonedSchedule(
      1, // Notification ID
      '어너러너',
      '같이 달릴 준비 되셨나요?',
      scheduledTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 같은 시간 반복
      androidScheduleMode: AndroidScheduleMode.exact, // 정확한 스케줄링
    );

  }
}
