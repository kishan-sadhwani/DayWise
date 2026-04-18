import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../../../core/utils/hive_setup.dart';
import '../../../core/services/notification_provider.dart';

final plannerViewModelProvider = NotifierProvider<PlannerViewModel, List<Task>>(
  PlannerViewModel.new,
);

class PlannerViewModel extends Notifier<List<Task>> {
  late Box<Task> _box;

  @override
  List<Task> build() {
    _box = Hive.box<Task>(HiveSetup.tasksBoxName);
    _cleanupOldTasks();
    return _loadTasksForToday();
  }

  void _cleanupOldTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final keysToDelete = <String>[];
    for (final task in _box.values) {
      final taskDate = DateTime(task.createdAt.year, task.createdAt.month, task.createdAt.day);
      if (taskDate.isBefore(today)) {
        keysToDelete.add(task.id);
      }
    }
    
    if (keysToDelete.isNotEmpty) {
      _box.deleteAll(keysToDelete);
    }
  }

  void checkMidnight() {
    _cleanupOldTasks();
    state = _loadTasksForToday();
  }

  List<Task> _loadTasksForToday() {
    final now = DateTime.now();
    final allTasks = _box.values.toList();
    
    // Filter tasks for today
    final todayTasks = allTasks.where((task) {
      return task.createdAt.year == now.year &&
             task.createdAt.month == now.month &&
             task.createdAt.day == now.day;
    }).toList();

    // Sort: Untimed tasks first based on creation time, then Timed tasks based on time.
    // Actually, UI needs untimed tasks in "Next" section at top, and Timed tasks mapped to timeline.
    // The view will separate them, but we sort them here as a generic order.
    // Let's sort timed tasks by time, untimed by created.
    todayTasks.sort((a, b) {
      if (a.time != null && b.time != null) {
        return a.time!.compareTo(b.time!);
      } else if (a.time == null && b.time == null) {
        return a.createdAt.compareTo(b.createdAt);
      }
      return a.time == null ? -1 : 1;
    });

    return todayTasks;
  }

  void addTask(String title, DateTime? time) {
    if (title.trim().isEmpty) return;

    final task = Task(
      id: const Uuid().v4(),
      title: title.trim(),
      time: time,
      createdAt: DateTime.now(),
    );

    _box.put(task.id, task);
    ref.read(notificationServiceProvider).scheduleNotification(task);
    
    state = _loadTasksForToday();
  }

  void updateTask(Task updatedTask) {
    _box.put(updatedTask.id, updatedTask);
    ref.read(notificationServiceProvider).scheduleNotification(updatedTask);
    
    state = _loadTasksForToday();
  }

  void completeTask(String id) {
    final task = _box.get(id);
    if (task != null) {
      final updatedTask = task.copyWith(isCompleted: true);
      _box.put(id, updatedTask);
      ref.read(notificationServiceProvider).cancelNotification(id);
      
      state = _loadTasksForToday();
    }
  }

  void deleteTask(String id) {
    _box.delete(id);
    ref.read(notificationServiceProvider).cancelNotification(id);
    
    state = _loadTasksForToday();
  }
}

final nextTaskProvider = Provider.autoDispose<String?>((ref) {
  final tasks = ref.watch(plannerViewModelProvider);
  if (tasks.isEmpty) return null;

  final now = DateTime.now();
  
  // Exclude completed or past timed tasks from next task logic
  final activeTasks = tasks.where((t) {
    if (t.isCompleted) return false;
    if (t.time != null && t.time!.isBefore(now)) return false;
    return true;
  }).toList();

  if (activeTasks.isEmpty) return null;

  // Active timed task or next upcoming timed task
  final timedTasks = activeTasks.where((t) => t.time != null).toList()
    ..sort((a, b) => a.time!.compareTo(b.time!));

  if (timedTasks.isNotEmpty) {
    return timedTasks.first.id;
  }

  // Fallback: First untimed task
  final untimedTasks = activeTasks.where((t) => t.time == null).toList();
  if (untimedTasks.isNotEmpty) {
    return untimedTasks.first.id;
  }

  return null;
});
