import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../domain/models/reminder.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: _onDidReceiveBackgroundNotificationResponse,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleReminderNotification(Reminder reminder) async {
    if (!reminder.notificationEnabled) return;
    if (reminder.dateTime.isBefore(DateTime.now())) return;

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Channel for reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = tz.TZDateTime.from(reminder.dateTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description ?? 'Reminder notification',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    if (reminder.repeat != RepeatType.none) {
      _scheduleRepeatingNotification(reminder);
    }
  }

  Future<void> _scheduleRepeatingNotification(Reminder reminder) async {
    DateTimeComponents? dateTimeComponents;

    switch (reminder.repeat) {
      case RepeatType.daily:
        dateTimeComponents = DateTimeComponents.time;
        break;
      case RepeatType.weekly:
        dateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
        break;
      case RepeatType.monthly:
        dateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
        break;
      default:
        return;
    }

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Channel for reminder notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = tz.TZDateTime.from(reminder.dateTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      reminder.id.hashCode,
      reminder.title,
      reminder.description ?? 'Reminder notification',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: dateTimeComponents,
      payload: reminder.id
    );
  }

  Future<void> scheduleRechargeReminder(MobileRecharge recharge) async {
    if (!recharge.reminderEnabled) return;

    final reminderDate = recharge.expiryDate.subtract(
      Duration(days: recharge.reminderDaysBefore),
    );

    if (reminderDate.isBefore(DateTime.now())) return;

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'recharge_channel',
      'Recharge Reminders',
      channelDescription: 'Channel for mobile recharge reminders',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledDate = tz.TZDateTime.from(reminderDate, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      recharge.id.hashCode,
      'Recharge Reminder',
      'Your ${recharge.operator} recharge for ${recharge.mobileNumber} expires in ${recharge.reminderDaysBefore} days',
      scheduledDate,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: recharge.id
    );
  }

  @pragma('vm:entry-point') // Required for Android when app is terminated
  static void _onDidReceiveBackgroundNotificationResponse(NotificationResponse notificationResponse) {
    debugPrint('Background notification payload: ${notificationResponse.payload}');
  }

  void _onDidReceiveNotificationResponse(NotificationResponse notificationResponse) {
    debugPrint('Notification payload: ${notificationResponse.payload}');
    // Implement navigation or logic here
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}