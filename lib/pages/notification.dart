// import 'dart:math';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// /*
// 앱을 사용하지 않은 경우만 알림을 보내는 기능 추가하기
// 마지막 사용 시각을 저장 (SharedPreferences에 저장)
// 사용자가 앱을 사용할 때마다 알림을 다시 예약
//  */
// class NotificationService {
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   NotificationService() {
//     _initializeNotifications();
//   }
//   // Android에서 알림 서비스를 초기화하는 데 필요한 설정
//   //알림을 보내기 전에 이 초기화가 필요
//   void _initializeNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('ic_learner_bear'); //알림 아이콘의 리소스 경로
//
//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//     );
//
//     await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
//   }
//
//   void scheduleNotification(bool isEnabled) async {
//     if (isEnabled) {
//       Random random = Random();
//       String message = random.nextBool() ? "같이 달릴 준비 되셨나요?" : "같이 달려보아요";
//
//       const AndroidNotificationDetails androidPlatformChannelSpecifics =
//       AndroidNotificationDetails(
//           'runnerLearner',  // 고유한 채널 ID
//           '어너러너', // 채널 이름
//           channelDescription: '알림 설정',  // 채널 설명
//           importance: Importance.max,
//           priority: Priority.high,
//           showWhen: false);
//
//       const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
//
//       await _flutterLocalNotificationsPlugin.zonedSchedule(
//         0,
//         '알림',
//         message,
//         tz.TZDateTime.now(tz.local).add(const Duration(seconds: 0)),  //푸시 알림 on 하면 알림 바로 오게 테스트
//         //tz.TZDateTime.now(tz.local).add(const Duration(days: 1)), // 하루 후에 알림 설정
//         platformChannelSpecifics,
//         androidAllowWhileIdle: true,
//         uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
//         matchDateTimeComponents: DateTimeComponents.time,
//       );
//
//       print("알림 울림");
//
//     } else {
//       print("알림이 비활성화되었습니다.");
//     }
//   }
// }
