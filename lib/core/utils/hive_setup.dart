import 'package:hive_flutter/hive_flutter.dart';
import '../../features/planner/models/task_adapter.dart';
import '../../features/planner/models/task.dart';

class HiveSetup {
  static const String tasksBoxName = 'tasksBox';

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    await Hive.openBox<Task>(tasksBoxName);
  }
}
