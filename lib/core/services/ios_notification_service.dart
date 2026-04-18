import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../features/planner/models/task.dart';
import 'notification_service.dart';

class IOSNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  @override
  Future<void> init() async {
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      iOS: iosSettings,
    );
    await _plugin.initialize(settings: initSettings);
  }

  @override
  Future<void> scheduleNotification(Task task) async {
    if (task.time == null || task.isCompleted) return;

    final now = DateTime.now();
    final scheduleTime = task.time!.subtract(const Duration(minutes: 5));

    final taskDate = DateTime(task.createdAt.year, task.createdAt.month, task.createdAt.day);
    final today = DateTime(now.year, now.month, now.day);
    
    // Do not schedule if time passed or from a previous day
    if (taskDate.isBefore(today)) return;
    if (scheduleTime.isBefore(now)) return;

    final id = task.id.hashCode;

    await _plugin.zonedSchedule(
      id: id,
      title: 'Upcoming: ${task.title}',
      body: 'Starts in 5 minutes',
      scheduledDate: tz.TZDateTime.from(scheduleTime, tz.local),
      notificationDetails: const NotificationDetails(
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  @override
  Future<void> cancelNotification(String taskId) async {
    await _plugin.cancel(id: taskId.hashCode);
  }
}
