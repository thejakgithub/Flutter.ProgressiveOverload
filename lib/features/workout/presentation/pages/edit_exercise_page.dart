import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';

class EditExercisePage extends StatelessWidget {
  const EditExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          title: const Text('Edit Exercise'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: const Color(0xFF121415),
                ),
                onPressed: () => context.pop(),
                child: const Text('Update'),
              ),
            ),
          ],
        ),
        body: ListView(
          children: const [
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'PUSH DAY',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ),
            _ExerciseSection(
              name: 'Decline Bench Press (Machine)',
              timer: 'Rest Timer: 3min 0s',
              initialRows: [
                ['W', '20', '12'],
                ['W', '20', '12'],
                ['1', '40', '12'],
                ['2', '40', '12'],
                ['3', '40', '12'],
              ],
            ),
            _ExerciseSection(
              name: 'Butterfly (Pec Deck)',
              timer: 'Rest Timer: 2min 0s',
              initialRows: [
                ['W', '29', '12'],
                ['1', '39', '12'],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSection extends StatefulWidget {
  const _ExerciseSection({
    required this.name,
    required this.timer,
    required this.initialRows,
  });

  final String name;
  final String timer;
  final List<List<String>> initialRows;

  @override
  State<_ExerciseSection> createState() => _ExerciseSectionState();
}

class _ExerciseSectionState extends State<_ExerciseSection> {
  late final List<List<String>> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.initialRows.map((r) => List<String>.from(r)).toList();
  }

  void _addSet() {
    setState(() {
      final nextNum = _rows.where((r) => r[0] != 'W').length + 1;
      _rows.add(['$nextNum', '-', '-']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.outline.withValues(alpha: 0.35)),
          bottom: BorderSide(color: AppColors.outline.withValues(alpha: 0.35)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceHighest,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fitness_center),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
                ),
              ),
              const Icon(Icons.more_vert, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Add routine notes here',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Text(
            widget.timer,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(child: Text('SET')),
              Expanded(child: Center(child: Text('KG'))),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('REPS'),
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.outline),
          for (final row in _rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      row[0],
                      style: TextStyle(
                        color: row[0] == 'W'
                            ? const Color(0xFFFFC627)
                            : AppColors.text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(child: Center(child: Text(row[1]))),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(row[2]),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(
                  color: AppColors.outline.withValues(alpha: 0.5),
                ),
                foregroundColor: AppColors.text,
              ),
              onPressed: _addSet,
              icon: const Icon(Icons.add),
              label: const Text('Add Set'),
            ),
          ),
        ],
      ),
    );
  }
}
