import '../../features/planner/models/task.dart';

abstract class NotificationService {
  Future<void> init();
  Future<void> scheduleNotification(Task task);
  Future<void> cancelNotification(String taskId);
}
