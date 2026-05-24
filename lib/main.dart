import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/network/supabase_bootstrap.dart';
import 'core/notifications/local_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseBootstrap.initialize();
  await LocalNotificationService.initialize();
  runApp(const ProgressiveOverloadApp());
}
