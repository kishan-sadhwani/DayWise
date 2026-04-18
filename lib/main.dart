import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/theme.dart';
import 'core/utils/hive_setup.dart';
import 'features/planner/view/planner_screen.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'core/services/ios_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await IOSNotificationService().init();
  await HiveSetup.init();
  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Planner',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const PlannerScreen(),
    );
  }
}
