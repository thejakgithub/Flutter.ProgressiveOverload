import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/supabase_bootstrap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/po_widgets.dart';

class AddExercisePage extends StatefulWidget {
  const AddExercisePage({super.key, this.day, this.templateName});

  final String? day;
  final String? templateName;

  @override
  State<AddExercisePage> createState() => _AddExercisePageState();
}

class _AddExercisePageState extends State<AddExercisePage> {
  String? _exerciseName;
  final List<List<String>> _sets = [];

  Future<void> _addExercise() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      builder: (_) => _ExercisePickerSheet(templateName: widget.templateName),
    );
    FocusManager.instance.primaryFocus?.unfocus();
    if (picked == null || !mounted) return;
    setState(() {
      _exerciseName = picked;
      if (_sets.isEmpty) _sets.add(['1', '-', '-']);
    });
  }

  void _addSet() {
    setState(() {
      _sets.add(['${_sets.length + 1}', '-', '-']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Add Exercise'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: const Color(0xFF121415),
                ),
                onPressed: () => context.pop(),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.day?.toUpperCase() ?? 'DAY',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 2),
            Text(
              widget.templateName ?? 'Workout',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 78,
              height: 4,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            if (_exerciseName == null)
              Text(
                'No exercise added yet',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
              )
            else ...[
              _ExerciseEditorHeader(
                name: _exerciseName!,
                timer: 'Rest Timer: OFF',
              ),
              const SizedBox(height: 12),
              _SetTable(rows: _sets),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54),
                  side: BorderSide(
                    color: AppColors.outline.withValues(alpha: 0.5),
                  ),
                  foregroundColor: AppColors.text,
                ),
                onPressed: _addSet,
                icon: const Icon(Icons.add),
                label: const Text('Add Set'),
              ),
            ],
            const SizedBox(height: 10),
            NeonPrimaryButton(
              label: 'Add exercise',
              icon: Icons.add,
              onPressed: _addExercise,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseEditorHeader extends StatelessWidget {
  const _ExerciseEditorHeader({required this.name, required this.timer});

  final String name;
  final String timer;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceHighest,
          ),
          child: const Icon(Icons.fitness_center),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const Icon(Icons.more_vert, color: AppColors.textMuted),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Add routine notes here',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
              Text(
                timer,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SetTable extends StatelessWidget {
  const _SetTable({required this.rows});

  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
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
          ),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Expanded(child: Text(row[0])),
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
        ],
      ),
    );
  }
}

// ── Exercise data ─────────────────────────────────────────────────────────────

enum _EquipmentCategory { gym, home, bodyweight }

enum _MuscleGroup {
  abdominals,
  abductors,
  adductors,
  biceps,
  calves,
  cardio,
  chest,
  forearms,
  fullBody,
  glutes,
  hamstrings,
  lats,
  lowerBack,
  neck,
  quadriceps,
  shoulders,
  traps,
  triceps,
  upperBack;

  String get label => switch (this) {
    abdominals => 'Abdominals',
    abductors => 'Abductors',
    adductors => 'Adductors',
    biceps => 'Biceps',
    calves => 'Calves',
    cardio => 'Cardio',
    chest => 'Chest',
    forearms => 'Forearms',
    fullBody => 'Full Body',
    glutes => 'Glutes',
    hamstrings => 'Hamstrings',
    lats => 'Lats',
    lowerBack => 'Lower Back',
    neck => 'Neck',
    quadriceps => 'Quadriceps',
    shoulders => 'Shoulders',
    traps => 'Traps',
    triceps => 'Triceps',
    upperBack => 'Upper Back',
  };

  String get emoji => switch (this) {
    abdominals => '⚡',
    abductors => '🦵',
    adductors => '🦵',
    biceps => '💪',
    calves => '🦿',
    cardio => '❤️',
    chest => '🫀',
    forearms => '🤜',
    fullBody => '🤸',
    glutes => '🏃',
    hamstrings => '🦵',
    lats => '🏊',
    lowerBack => '🔩',
    neck => '🦒',
    quadriceps => '🦵',
    shoulders => '🏋️',
    traps => '🦁',
    triceps => '💪',
    upperBack => '🏊',
  };
}

class _Exercise {
  const _Exercise(this.name, this.muscle, this.category, this.muscleGroup);
  final String name;
  final String muscle;
  final _EquipmentCategory category;
  final _MuscleGroup muscleGroup;
}

const _kPopularExercises = [
  _Exercise(
    'Bench Press (Barbell)',
    'Chest',
    _EquipmentCategory.gym,
    _MuscleGroup.chest,
  ),
  _Exercise(
    'Bench Press (Dumbbell)',
    'Chest',
    _EquipmentCategory.home,
    _MuscleGroup.chest,
  ),
  _Exercise(
    'Bent Over Row (Barbell)',
    'Upper Back',
    _EquipmentCategory.gym,
    _MuscleGroup.upperBack,
  ),
  _Exercise(
    'Bicep Curl (Dumbbell)',
    'Biceps',
    _EquipmentCategory.home,
    _MuscleGroup.biceps,
  ),
  _Exercise(
    'Cable Fly Crossovers',
    'Chest',
    _EquipmentCategory.gym,
    _MuscleGroup.chest,
  ),
  _Exercise(
    'Deadlift (Barbell)',
    'Glutes',
    _EquipmentCategory.gym,
    _MuscleGroup.glutes,
  ),
  _Exercise(
    'Face Pull',
    'Shoulders',
    _EquipmentCategory.gym,
    _MuscleGroup.shoulders,
  ),
  _Exercise(
    'Hammer Curl (Dumbbell)',
    'Biceps',
    _EquipmentCategory.home,
    _MuscleGroup.biceps,
  ),
  _Exercise(
    'Incline Bench Press (Dumbbell)',
    'Chest',
    _EquipmentCategory.home,
    _MuscleGroup.chest,
  ),
  _Exercise(
    'Lat Pulldown (Cable)',
    'Lats',
    _EquipmentCategory.gym,
    _MuscleGroup.lats,
  ),
  _Exercise(
    'Leg Press',
    'Quads',
    _EquipmentCategory.gym,
    _MuscleGroup.quadriceps,
  ),
  _Exercise(
    'Overhead Press (Barbell)',
    'Shoulders',
    _EquipmentCategory.gym,
    _MuscleGroup.shoulders,
  ),
  _Exercise(
    'Pull Up',
    'Lats',
    _EquipmentCategory.bodyweight,
    _MuscleGroup.lats,
  ),
  _Exercise(
    'Romanian Deadlift',
    'Hamstrings',
    _EquipmentCategory.gym,
    _MuscleGroup.hamstrings,
  ),
  _Exercise(
    'Squat (Barbell)',
    'Quads',
    _EquipmentCategory.gym,
    _MuscleGroup.quadriceps,
  ),
  _Exercise(
    'Tricep Pushdown (Cable)',
    'Triceps',
    _EquipmentCategory.gym,
    _MuscleGroup.triceps,
  ),
];

// ── Exercise Picker Sheet ─────────────────────────────────────────────────────

// Equipment names that map to each category (mirrors equipment_selection_page)
const _kGymEquipmentNames = {
  'Smith Machine', 'Cable Machine', 'Squat Rack', 'Chest Press',
  'Incline Chest Press', 'Chest Dip', 'Pec Fly', 'Pull-up Bar',
  'Lat Pulldown', 'Leg Extension', 'Leg Press', 'Leg Curl',
  'Hip Adduction', 'Hip Thrust', 'Seated Cable Row', 'Shoulder Press',
  'Bicep Curl Machine', 'Tricep Pushdown', 'Calf Raise Machine', 'Leg Raise',
  'Barbell', // barbell exercises are categorised as gym
};
const _kHomeEquipmentNames = {
  'Dumbbells',
  'Bench',
  'Kettlebell',
  'Resistance Bands',
};

const _kPushTemplateMuscles = <_MuscleGroup>{
  _MuscleGroup.abdominals,
  _MuscleGroup.biceps,
  _MuscleGroup.cardio,
  _MuscleGroup.chest,
  _MuscleGroup.forearms,
  _MuscleGroup.fullBody,
  _MuscleGroup.neck,
  _MuscleGroup.shoulders,
  _MuscleGroup.traps,
  _MuscleGroup.triceps,
};

const _kPullTemplateMuscles = <_MuscleGroup>{
  _MuscleGroup.abdominals,
  _MuscleGroup.biceps,
  _MuscleGroup.cardio,
  _MuscleGroup.forearms,
  _MuscleGroup.fullBody,
  _MuscleGroup.lats,
  _MuscleGroup.lowerBack,
  _MuscleGroup.neck,
  _MuscleGroup.shoulders,
  _MuscleGroup.traps,
  _MuscleGroup.triceps,
  _MuscleGroup.upperBack,
};

const _kLegTemplateMuscles = <_MuscleGroup>{
  _MuscleGroup.abdominals,
  _MuscleGroup.abductors,
  _MuscleGroup.adductors,
  _MuscleGroup.calves,
  _MuscleGroup.cardio,
  _MuscleGroup.fullBody,
  _MuscleGroup.glutes,
  _MuscleGroup.hamstrings,
  _MuscleGroup.quadriceps,
};

const _kUpperTemplateMuscles = <_MuscleGroup>{
  _MuscleGroup.abdominals,
  _MuscleGroup.biceps,
  _MuscleGroup.cardio,
  _MuscleGroup.chest,
  _MuscleGroup.forearms,
  _MuscleGroup.fullBody,
  _MuscleGroup.lats,
  _MuscleGroup.lowerBack,
  _MuscleGroup.neck,
  _MuscleGroup.shoulders,
  _MuscleGroup.traps,
  _MuscleGroup.triceps,
  _MuscleGroup.upperBack,
};

const _kLowerTemplateMuscles = <_MuscleGroup>{
  _MuscleGroup.abdominals,
  _MuscleGroup.abductors,
  _MuscleGroup.adductors,
  _MuscleGroup.calves,
  _MuscleGroup.cardio,
  _MuscleGroup.fullBody,
  _MuscleGroup.glutes,
  _MuscleGroup.hamstrings,
  _MuscleGroup.lowerBack,
};

Set<_EquipmentCategory> _categoriesFromEquipment(
  List<String> list,
  bool hasBodyweight,
) {
  final result = <_EquipmentCategory>{};
  for (final item in list) {
    if (_kGymEquipmentNames.contains(item)) result.add(_EquipmentCategory.gym);
    if (_kHomeEquipmentNames.contains(item)) {
      result.add(_EquipmentCategory.home);
    }
  }
  if (hasBodyweight) result.add(_EquipmentCategory.bodyweight);
  // If nothing matched, fall back to showing everything
  return result.isEmpty
      ? {
          _EquipmentCategory.gym,
          _EquipmentCategory.home,
          _EquipmentCategory.bodyweight,
        }
      : result;
}

/// Returns null when the template is unknown (show all).
Set<_MuscleGroup>? _musclesForTemplate(String? template) {
  if (template == null) return null;
  final t = template.toLowerCase();
  if (t.contains('push')) return _kPushTemplateMuscles;
  if (t.contains('pull')) return _kPullTemplateMuscles;
  if (t.contains('leg')) return _kLegTemplateMuscles;
  if (t.contains('upper')) return _kUpperTemplateMuscles;
  if (t.contains('lower')) return _kLowerTemplateMuscles;
  // Full Body or anything else → show all
  return null;
}

class _ExercisePickerSheet extends StatefulWidget {
  const _ExercisePickerSheet({this.templateName});

  final String? templateName;

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  _EquipmentCategory? _equipmentFilter;
  _MuscleGroup? _muscleFilter;
  Set<_EquipmentCategory>? _allowedCategories; // null until loaded

  @override
  void initState() {
    super.initState();
    _loadUserEquipment();
  }

  Future<void> _loadUserEquipment() async {
    final client = SupabaseBootstrap.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) return;
    try {
      final row = await client
          .from('user_equipment')
          .select('equipment_list, has_bodyweight')
          .eq('user_id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 6), onTimeout: () => null);
      if (row == null || !mounted) return;
      final list = (row['equipment_list'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList();
      final bodyweight = (row['has_bodyweight'] as bool?) ?? false;
      setState(() {
        _allowedCategories = _categoriesFromEquipment(list, bodyweight);
      });
    } catch (_) {
      // Fail silently — show all equipment on error
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_Exercise> get _filtered {
    final allowedMuscles = _musclesForTemplate(widget.templateName);
    final normalizedQuery = _query.trim().toLowerCase();
    return _kPopularExercises.where((e) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
          e.name.toLowerCase().contains(normalizedQuery) ||
          e.muscle.toLowerCase().contains(normalizedQuery);
      // When a specific filter is chosen use it; otherwise restrict to the
      // user's own equipment categories (if loaded).
      final matchesEquipment = _equipmentFilter != null
          ? e.category == _equipmentFilter
          : (_allowedCategories == null ||
                _allowedCategories!.contains(e.category));
      // When a specific muscle is chosen use it; otherwise restrict to the
      // template's allowed muscles (if any).
      final matchesMuscle = _muscleFilter != null
          ? e.muscleGroup == _muscleFilter
          : (allowedMuscles == null || allowedMuscles.contains(e.muscleGroup));
      return matchesQuery && matchesEquipment && matchesMuscle;
    }).toList();
  }

  String get _equipmentLabel {
    return switch (_equipmentFilter) {
      _EquipmentCategory.gym => 'Gym',
      _EquipmentCategory.home => 'Home',
      _EquipmentCategory.bodyweight => 'Body Weight',
      null => 'All Equipment',
    };
  }

  Future<void> _openEquipmentFilter() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await showModalBottomSheet<Object>(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EquipmentFilterSheet(
        current: _equipmentFilter,
        allowed: _allowedCategories,
      ),
    );
    FocusManager.instance.primaryFocus?.unfocus();
    if (result == null || !mounted) return; // dismissed — no change
    setState(() {
      _equipmentFilter = result == _kClearFilter
          ? null
          : result as _EquipmentCategory;
    });
  }

  String get _muscleLabel => _muscleFilter?.label ?? 'All Muscles';

  Future<void> _openMuscleFilter() async {
    final allowed = _musclesForTemplate(widget.templateName);
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await showModalBottomSheet<Object>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) =>
          _MuscleFilterSheet(current: _muscleFilter, allowed: allowed),
    );
    FocusManager.instance.primaryFocus?.unfocus();
    if (result == null || !mounted) return;
    setState(() {
      _muscleFilter = result == _kClearFilter ? null : result as _MuscleGroup;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Column(
      children: [
        // ── Top bar ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Add Exercise',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Create',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        // ── Search bar ───────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search exercise',
              prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.surfaceContainer,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        // ── Filter chips ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: _FilterChip(
                  label: _equipmentLabel,
                  active: _equipmentFilter != null,
                  onTap: _openEquipmentFilter,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FilterChip(
                  label: _muscleLabel,
                  active: _muscleFilter != null,
                  onTap: _openMuscleFilter,
                ),
              ),
            ],
          ),
        ),
        // ── List ─────────────────────────────────────────────────────────────
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  child: Text(
                    _query.isEmpty &&
                            _equipmentFilter == null &&
                            _muscleFilter == null
                        ? 'Popular Exercises'
                        : 'Results',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 72,
                  color: AppColors.outline.withValues(alpha: 0.25),
                ),
                itemBuilder: (context, i) {
                  final ex = filtered[i];
                  return _ExerciseRow(
                    name: ex.name,
                    muscle: ex.muscle,
                    onTap: () => Navigator.pop(context, ex.name),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.onTap,
    this.active = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          border: active
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.6))
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: active ? AppColors.primary : null,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: active ? AppColors.primary : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Equipment Filter Sheet ────────────────────────────────────────────────────

// Sentinel to distinguish "All Equipment selected" from "sheet dismissed"
const _kClearFilter = Object();

class _EquipmentFilterSheet extends StatelessWidget {
  const _EquipmentFilterSheet({this.current, this.allowed});

  final _EquipmentCategory? current;

  /// If non-null, only these categories are shown.
  final Set<_EquipmentCategory>? allowed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Equipment', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            _FilterOption(
              label: 'All Equipment',
              icon: Icons.apps,
              selected: current == null,
              onTap: () => Navigator.pop(context, _kClearFilter),
            ),
            if (allowed == null ||
                allowed!.contains(_EquipmentCategory.gym)) ...[
              const SizedBox(height: 8),
              _FilterOption(
                label: 'Gym',
                icon: Icons.fitness_center,
                selected: current == _EquipmentCategory.gym,
                onTap: () => Navigator.pop(context, _EquipmentCategory.gym),
              ),
            ],
            if (allowed == null ||
                allowed!.contains(_EquipmentCategory.home)) ...[
              const SizedBox(height: 8),
              _FilterOption(
                label: 'Home',
                icon: Icons.home,
                selected: current == _EquipmentCategory.home,
                onTap: () => Navigator.pop(context, _EquipmentCategory.home),
              ),
            ],
            if (allowed == null ||
                allowed!.contains(_EquipmentCategory.bodyweight)) ...[
              const SizedBox(height: 8),
              _FilterOption(
                label: 'Body Weight',
                icon: Icons.accessibility_new,
                selected: current == _EquipmentCategory.bodyweight,
                onTap: () =>
                    Navigator.pop(context, _EquipmentCategory.bodyweight),
              ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surfaceLow,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: selected ? AppColors.primary : null,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? AppColors.primary : AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Muscle Filter Sheet ───────────────────────────────────────────────────────

class _MuscleFilterSheet extends StatelessWidget {
  const _MuscleFilterSheet({this.current, this.allowed});

  final _MuscleGroup? current;

  /// If non-null, only these groups are shown (plus the "All" option).
  final Set<_MuscleGroup>? allowed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Muscles', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            // "All Muscles" option
            _MuscleOption(
              label: 'All Muscles',
              emoji: '🏅',
              selected: current == null,
              onTap: () => Navigator.pop(context, _kClearFilter),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final group in _MuscleGroup.values)
                      if (allowed == null || allowed!.contains(group)) ...[
                        _MuscleOption(
                          label: group.label,
                          emoji: group.emoji,
                          selected: current == group,
                          onTap: () => Navigator.pop(context, group),
                        ),
                        const SizedBox(height: 8),
                      ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MuscleOption extends StatelessWidget {
  const _MuscleOption({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.surfaceLow,
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: selected ? AppColors.primary : null,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? AppColors.primary : AppColors.outline,
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({
    required this.name,
    required this.muscle,
    required this.onTap,
  });

  final String name;
  final String muscle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceHighest,
              ),
              child: const Icon(
                Icons.fitness_center,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    muscle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Icon(Icons.show_chart, color: AppColors.outline, size: 22),
          ],
        ),
      ),
    );
  }
}
