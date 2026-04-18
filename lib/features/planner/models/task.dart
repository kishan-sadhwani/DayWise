import 'package:hive/hive.dart';

/// Core domain model representing a single task inside the DayWise app.
/// Mapped natively via Hive for local non-volatile storage.
@HiveType(typeId: 0)
class Task {
  /// Unique identifier generated via UUID v4.
  @HiveField(0)
  final String id;

  /// User-defined display text representing the task.
  @HiveField(1)
  final String title;

  /// Specific time the task is scheduled for. If null, the task is considered "untimed".
  @HiveField(2)
  final DateTime? time;

  /// Tracks if the user has marked this task as complete.
  @HiveField(3)
  final bool isCompleted;

  /// Date the task was created. Used strictly for chronological garbage cleanup.
  @HiveField(4)
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.time,
    this.isCompleted = false,
    required this.createdAt,
  });

  Task copyWith({
    String? id,
    String? title,
    DateTime? time,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      time: time ?? this.time,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
