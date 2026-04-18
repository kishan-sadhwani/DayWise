import '../../features/planner/models/task.dart';

/// Abstract interface defining the core local notification contract.
/// Ensures platform-specific implementations remain fully decoupled from business logic.
abstract class NotificationService {
  /// Initializes the underlying notification plugins and configurations.
  Future<void> init();
  
  /// Schedules a future notification if the task qualifies (e.g. valid future timestamp).
  Future<void> scheduleNotification(Task task);

  /// Cancels an existing actively scheduled notification using the `taskId`.
  Future<void> cancelNotification(String taskId);
}
