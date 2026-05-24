import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'weekly_planner_page.dart';

class WeeklyPlannerOptionsPopupPage extends StatelessWidget {
  const WeeklyPlannerOptionsPopupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const WeeklyPlannerPage(showBottomNav: false),
        Container(color: Colors.black.withValues(alpha: 0.6)),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(width: 50, height: 4, decoration: BoxDecoration(color: AppColors.surfaceHighest, borderRadius: BorderRadius.circular(999))),
                    ),
                    const SizedBox(height: 14),
                    Text('Workout Options', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text('Push Day - Monday', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted)),
                    const Divider(height: 24, color: AppColors.outline),
                    _menuItem(context, Icons.edit, 'Edit Workout'),
                    _menuItem(context, Icons.copy_all, 'Duplicate'),
                    _menuItem(context, Icons.share, 'Share'),
                    _menuItem(context, Icons.delete_outline, 'Clear Day', destructive: true),
                    const Divider(height: 24, color: AppColors.outline),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'CANCEL',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(letterSpacing: 2, color: AppColors.textMuted),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String label, {bool destructive = false}) {
    final color = destructive ? const Color(0xFFF5AFA8) : AppColors.text;
    final iconColor = destructive ? const Color(0xFFF5AFA8) : AppColors.primary;
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 12),
            Text(label, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
