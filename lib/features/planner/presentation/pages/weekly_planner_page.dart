import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/supabase_bootstrap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/po_widgets.dart';

const _kDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const _kTemplates = [
  ('Full Body', 'Compound exercises'),
  ('Upper Body', 'Compound Focus'),
  ('Lower Body', 'Compound Focus'),
  ('Push Day', 'Chest, Shoulders, Triceps/Biceps'),
  ('Pull Day', 'Back, Biceps/Triceps, Forearms'),
  ('Leg Day', 'Quads, Hamstrings, Calves'),
  ('Rest Day', 'Recovery Focus'),
];

class WeeklyPlannerPage extends StatefulWidget {
  const WeeklyPlannerPage({super.key, this.showBottomNav = true});

  final bool showBottomNav;

  @override
  State<WeeklyPlannerPage> createState() => _WeeklyPlannerPageState();
}

class _WeeklyPlannerPageState extends State<WeeklyPlannerPage> {
  bool _isSaving = false;

  final Map<String, String?> _weekPlan = {for (final d in _kDays) d: null};
  final Map<String, List<String>> _weekExercises = {
    for (final d in _kDays) d: [],
  };

  Future<void> _savePlanToDatabase() async {
    setState(() => _isSaving = true);

    try {
      final userId = SupabaseBootstrap.client?.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final planData = {
        for (final d in _kDays)
          d: {'template': _weekPlan[d], 'exercises': _weekExercises[d]},
      };
      await SupabaseBootstrap.client!.from('user_weekly_plan').upsert({
        'user_id': userId,
        'is_completed': true,
        'plan_data': planData,
      }, onConflict: 'user_id');

      if (!mounted) return;
      context.go('/workout/daily');
    } catch (e) {
      setState(() => _isSaving = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openTemplatePicker(String templateName) {
    FocusManager.instance.primaryFocus?.unfocus();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _TemplateDayPickerSheet(
        templateName: templateName,
        weekPlan: Map.from(_weekPlan),
        onConfirm: (updated) => setState(() => _weekPlan.addAll(updated)),
      ),
    );
  }

  void _openExerciseAdder(String day) {
    FocusManager.instance.primaryFocus?.unfocus();
    context.push('/workout/add', extra: (day, _weekPlan[day]));
  }

  void _openDayPicker(String day) {
    FocusManager.instance.primaryFocus?.unfocus();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _DayTemplatePickerSheet(
        day: day,
        currentTemplate: _weekPlan[day],
        onSelect: (template) {
          setState(() => _weekPlan[day] = template);
          Navigator.pop(ctx);
        },
        onClear: () {
          setState(() => _weekPlan[day] = null);
          Navigator.pop(ctx);
        },
      ),
    );
  }

  String? _getTemplateSubtitle(String? name) {
    if (name == null) return null;
    for (final t in _kTemplates) {
      if (t.$1 == name) return t.$2;
    }
    return null;
  }

  Widget _loadingOverlay() {
    return const ColoredBox(
      color: Colors.black54,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'PROGRESSIVE OVERLOAD',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.primary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              children: [
                Text(
                  'Weekly Planner',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap a template to add it to your week. Exercises are tailored to your selected gym equipment.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Icon(Icons.bolt, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'SMART TEMPLATES',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const Spacer(),
                    const Tooltip(
                      message: 'Filtered by your equipment',
                      triggerMode: TooltipTriggerMode.tap,
                      child: Icon(
                        Icons.info_outline,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 124,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final t in _kTemplates)
                        _TemplateCard(
                          title: t.$1,
                          subtitle: t.$2,
                          onTap: () => _openTemplatePicker(t.$1),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "THIS WEEK'S PLAN",
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 10),
                for (final day in _kDays) ...[
                  _DayTile(
                    day: day,
                    templateName: _weekPlan[day],
                    templateSubtitle: _getTemplateSubtitle(_weekPlan[day]),
                    exercises: _weekExercises[day]!,
                    onTap: () => _openDayPicker(day),
                    onAddExercise: () => _openExerciseAdder(day),
                  ),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 6),
                NeonPrimaryButton(
                  label: 'Save Weekly Plan',
                  icon: Icons.save,
                  onPressed: _isSaving ? null : _savePlanToDatabase,
                ),
              ],
            ),
          ),
        ),
        if (_isSaving) _loadingOverlay(),
      ],
    );
  }
}

class _TemplateCard extends StatelessWidget {
  const _TemplateCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 186,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'TEMPLATE',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 10),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.onTap,
    required this.exercises,
    required this.onAddExercise,
    this.templateName,
    this.templateSubtitle,
  });

  final String day;
  final String? templateName;
  final String? templateSubtitle;
  final List<String> exercises;
  final VoidCallback onTap;
  final VoidCallback onAddExercise;

  @override
  Widget build(BuildContext context) {
    return KineticCard(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 60,
              child: Text(day, style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: templateName != null
                  ? _AssignedContent(
                      name: templateName!,
                      subtitle: templateSubtitle ?? '',
                      exercises: exercises,
                      onAddExercise: onAddExercise,
                    )
                  : const _EmptyContent(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignedContent extends StatelessWidget {
  const _AssignedContent({
    required this.name,
    required this.subtitle,
    required this.exercises,
    required this.onAddExercise,
  });

  final String name;
  final String subtitle;
  final List<String> exercises;
  final VoidCallback onAddExercise;

  @override
  Widget build(BuildContext context) {
    final isRest = name == 'Rest Day';
    final iconData = isRest ? Icons.nightlight_round : Icons.fitness_center;
    final accentColor = isRest ? AppColors.textMuted : AppColors.primary;
    final bgColor = isRest
        ? AppColors.surfaceLow
        : AppColors.primary.withValues(alpha: 0.07);
    final borderColor = isRest
        ? AppColors.outline.withValues(alpha: 0.4)
        : AppColors.primary.withValues(alpha: 0.5);
    final iconBg = isRest
        ? AppColors.surfaceHighest
        : AppColors.primary.withValues(alpha: 0.15);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
        color: bgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: Theme.of(context).textTheme.titleMedium),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.edit_outlined,
                size: 16,
                color: AppColors.textMuted,
              ),
            ],
          ),
          if (exercises.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final ex in exercises)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHighest,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.outline.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      ex,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (!isRest) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: onAddExercise,
              behavior: HitTestBehavior.opaque,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_circle_outline, size: 14, color: accentColor),
                  const SizedBox(width: 4),
                  Text(
                    'Add exercise',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: accentColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.add_circle_outline,
            color: AppColors.textMuted,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            'Tap to assign a workout',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet: assign template → pick days ────────────────────────────────

class _TemplateDayPickerSheet extends StatefulWidget {
  const _TemplateDayPickerSheet({
    required this.templateName,
    required this.weekPlan,
    required this.onConfirm,
  });

  final String templateName;
  final Map<String, String?> weekPlan;
  final void Function(Map<String, String?>) onConfirm;

  @override
  State<_TemplateDayPickerSheet> createState() =>
      _TemplateDayPickerSheetState();
}

class _TemplateDayPickerSheetState extends State<_TemplateDayPickerSheet> {
  late final Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.weekPlan.entries
        .where((e) => e.value == widget.templateName)
        .map((e) => e.key)
        .toSet();
  }

  void _confirm() {
    final updated = Map<String, String?>.from(widget.weekPlan);
    for (final k in updated.keys.toList()) {
      if (updated[k] == widget.templateName) updated[k] = null;
    }
    for (final d in _selected) {
      updated[d] = widget.templateName;
    }
    widget.onConfirm(updated);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineMedium,
                children: [
                  const TextSpan(text: 'Assign '),
                  TextSpan(
                    text: widget.templateName,
                    style: const TextStyle(color: AppColors.primary),
                  ),
                  const TextSpan(text: ' to'),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Select one or more days',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 14),
            for (final day in _kDays)
              _DayCheckRow(
                day: day,
                isSelected: _selected.contains(day),
                conflictLabel:
                    widget.weekPlan[day] != null &&
                        widget.weekPlan[day] != widget.templateName
                    ? widget.weekPlan[day]
                    : null,
                onTap: () => setState(() {
                  if (_selected.contains(day)) {
                    _selected.remove(day);
                  } else {
                    _selected.add(day);
                  }
                }),
              ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: const Color(0xFF161E00),
                  minimumSize: const Size.fromHeight(54),
                ),
                onPressed: _confirm,
                child: const Text('Confirm'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCheckRow extends StatelessWidget {
  const _DayCheckRow({
    required this.day,
    required this.isSelected,
    required this.onTap,
    this.conflictLabel,
  });

  final String day;
  final bool isSelected;
  final String? conflictLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surfaceLow,
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Text(day, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 8),
            if (conflictLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  conflictLabel!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
              ),
            const Spacer(),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bottom sheet: pick template for a day ────────────────────────────────────

class _DayTemplatePickerSheet extends StatelessWidget {
  const _DayTemplatePickerSheet({
    required this.day,
    required this.onSelect,
    required this.onClear,
    this.currentTemplate,
  });

  final String day;
  final String? currentTemplate;
  final void Function(String) onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 52,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.headlineMedium,
                children: [
                  const TextSpan(text: 'Workout for '),
                  TextSpan(
                    text: day,
                    style: const TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final t in _kTemplates)
              GestureDetector(
                onTap: () => onSelect(t.$1),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.surfaceLow,
                    border: Border.all(
                      color: currentTemplate == t.$1
                          ? AppColors.primary
                          : AppColors.outline.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.$1,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              t.$2,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        currentTemplate == t.$1
                            ? Icons.check_circle
                            : Icons.circle_outlined,
                        color: currentTemplate == t.$1
                            ? AppColors.primary
                            : AppColors.outline,
                      ),
                    ],
                  ),
                ),
              ),
            if (currentTemplate != null) ...[
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onClear,
                  child: Text(
                    'Remove workout',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
