import 'package:flutter/material.dart';

import '../../../../core/notifications/local_notification_service.dart';
import '../../../../core/notifications/push_notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/po_widgets.dart';

class DailyWorkoutPage extends StatelessWidget {
  const DailyWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Icons.bolt, color: AppColors.primary),
              Text(
                'Progressive Overload',
                style: TextStyle(color: AppColors.primary),
              ),
              Icon(Icons.settings, color: AppColors.primary),
            ],
          ),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              SizedBox(
                height: 86,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _DayChip('MON', '12'),
                    _DayChip('TUE', '13'),
                    _DayChip('WED', '14', active: true),
                    _DayChip('THU', '15'),
                    _DayChip('FRI', '16'),
                    _DayChip('SAT', '17'),
                    _DayChip('SUN', '18'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'TODAY\'S WORKOUT',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'PUSH DAY',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  const _DurationBadge(),
                ],
              ),
              const SizedBox(height: 12),
              const NeonPrimaryButton(
                label: 'START WORKOUT',
                icon: Icons.play_arrow,
              ),
              const SizedBox(height: 16),
              const _ExerciseCard(
                name: 'Barbell Bench Press',
                sets: '4 Sets • 8-10 Reps',
                target: '225 lbs',
              ),
              const SizedBox(height: 12),
              const _ExerciseCard(
                name: 'Overhead Dumbbell Press',
                sets: '3 Sets • 10-12 Reps',
                target: '60 lbs',
              ),
              const SizedBox(height: 12),
              const _ExerciseCard(
                name: 'Tricep Rope Pushdown',
                sets: '4 Sets • 12-15 Reps',
                target: '45 lbs',
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  minimumSize: const Size.fromHeight(56),
                  foregroundColor: AppColors.primary,
                ),
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add Exercise'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.textMuted),
                  minimumSize: const Size.fromHeight(56),
                  foregroundColor: AppColors.text,
                ),
                onPressed: () async {
                  await LocalNotificationService.showWorkoutReminderNow();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification sent.')),
                  );
                },
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('Test Notification'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.textMuted),
                  minimumSize: const Size.fromHeight(56),
                  foregroundColor: AppColors.text,
                ),
                onPressed: () async {
                  try {
                    await PushNotificationService.syncCurrentDeviceToken();
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Push token synced to Supabase.'),
                      ),
                    );
                  } catch (error) {
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(error.toString())));
                  }
                },
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Sync Push Token'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // _durationBadge removed — see _DurationBadge widget below
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.name,
    required this.sets,
    required this.target,
  });

  final String name;
  final String sets;
  final String target;

  @override
  Widget build(BuildContext context) {
    return KineticCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.image, color: Colors.white38),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          'Target:\n$target',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sets,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_vert, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceHighest,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: const Row(
              children: [
                Expanded(child: Text('SET')),
                Expanded(child: Center(child: Text('LBS'))),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('REPS'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          for (final row in const ['1', '2', '3', '4'])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Row(
                children: [
                  Expanded(child: Text(row)),
                  const Expanded(child: Center(child: Text('225'))),
                  const Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text('8-10'),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip(this.day, this.date, {this.active = false});

  final String day;
  final String date;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: active ? 64 : 56,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              color: active ? const Color(0xFF121415) : AppColors.textMuted,
            ),
          ),
          Text(
            date,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: active ? const Color(0xFF121415) : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  const _DurationBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: const Row(
        children: [
          Icon(Icons.schedule, size: 16),
          SizedBox(width: 4),
          Text('65 min'),
        ],
      ),
    );
  }
}
