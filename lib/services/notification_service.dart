import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz; // 引入 timezone 包
import 'package:timezone/data/latest.dart' as tz;


class NotificationService {
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  NotificationService._();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // 使用你的应用图标

    final InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    // 初始化时区数据
    tz.initializeTimeZones();
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      // onDidReceiveNotificationResponse: (NotificationResponse response) {
      //   // 处理通知点击事件 (如果需要)
      // },
    );
  }

  // 显示通知
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload, // 可选的负载数据
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'your_channel_id', // 频道 ID
      'your_channel_name', // 频道名称
      channelDescription: 'your_channel_description', // 频道描述
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
  // 定时通知 (例如，纪念日提醒)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    final platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    // 获取当前时区
    final location = tz.local;
    // 将 DateTime 转换为 TZDateTime
    final scheduledTZDateTime = tz.TZDateTime.from(scheduledDate, location);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZDateTime, // 使用 TZDateTime
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode
          .exactAllowWhileIdle, // 指定 Android 调度模式 (这里使用精确的)
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }

  // 取消通知
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // 取消所有通知
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
//在main.dart中初始化
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await NotificationService.instance.init(); // 初始化通知服务
//   ...
// }