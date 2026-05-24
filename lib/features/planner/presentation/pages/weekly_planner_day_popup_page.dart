import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'weekly_planner_page.dart';

class WeeklyPlannerDayPopupPage extends StatelessWidget {
  const WeeklyPlannerDayPopupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const WeeklyPlannerPage(showBottomNav: false),
        Container(color: Colors.black.withValues(alpha: 0.6)),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 52, height: 4, decoration: BoxDecoration(color: AppColors.surfaceHighest, borderRadius: BorderRadius.circular(999))),
                const SizedBox(height: 14),
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineMedium,
                    children: const [
                      TextSpan(text: 'Select Day for '),
                      TextSpan(text: 'Push Day', style: TextStyle(color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ..._days(context),
                const SizedBox(height: 14),
                const SizedBox(width: double.infinity, child: _AddToPlanButton()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _days(BuildContext context) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return List.generate(days.length, (i) {
      final selected = i == 0;
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surfaceLow,
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Expanded(child: Text(days[i], style: Theme.of(context).textTheme.titleMedium)),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? AppColors.primary : AppColors.outline,
            ),
          ],
        ),
      );
    });
  }
}

class _AddToPlanButton extends StatelessWidget {
  const _AddToPlanButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: const Color(0xFF161E00),
        minimumSize: const Size.fromHeight(54),
      ),
      onPressed: () {},
      child: const Text('Add to Plan'),
    );
  }
}
