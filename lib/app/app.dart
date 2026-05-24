import 'package:flutter/material.dart';

import 'router/app_router.dart';
import '../core/theme/app_theme.dart';

class ProgressiveOverloadApp extends StatelessWidget {
  const ProgressiveOverloadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Progressive Overload',
      themeMode: ThemeMode.dark,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      routerConfig: AppRouter.router,
    );
  }
}
