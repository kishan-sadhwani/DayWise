import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ios_notification_service.dart';
import 'notification_service.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return IOSNotificationService();
});
