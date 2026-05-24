import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/supabase_bootstrap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/po_widgets.dart';

class EquipmentSelectionPage extends StatefulWidget {
  const EquipmentSelectionPage({super.key});

  @override
  State<EquipmentSelectionPage> createState() => _EquipmentSelectionPageState();
}

class _EquipmentSelectionPageState extends State<EquipmentSelectionPage> {
  // All available machine names (matches browse_machines_page)
  static const _allMachineNames = <String>{
    'Smith Machine',
    'Cable Machine',
    'Squat Rack',
    'Chest Press',
    'Incline Chest Press',
    'Chest Dip',
    'Pec Fly',
    'Pull-up Bar',
    'Lat Pulldown',
    'Leg Extension',
    'Leg Press',
    'Leg Curl',
    'Hip Adduction',
    'Hip Thrust',
    'Seated Cable Row',
    'Shoulder Press',
    'Bicep Curl Machine',
    'Tricep Pushdown',
    'Calf Raise Machine',
    'Leg Raise',
  };

  static const _gymEquipment = <String>[
    'Smith Machine',
    'Cable Machine',
    'Chest Press',
    'Pull-up Bar',
    'Lat Pulldown',
    'Leg Press',
    'Leg Extension',
    'See All Machines',
    // 'Add Custom',
  ];

  static const _homeEquipment = <String>[
    'Barbell',
    'Dumbbells',
    'Bench',
    'Kettlebell',
    'Resistance Bands',
  ];

  final Set<String> _selectedEquipment = <String>{};
  bool _bodyweightSelected = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadEquipmentFromSupabase();
  }

  Future<void> _onContinue(bool isEditMode) async {
    if (_selectedEquipment.isEmpty && !_bodyweightSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one equipment option.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _saveEquipmentToSupabase();

      if (!mounted) {
        return;
      }

      if (isEditMode) {
        // In edit mode, go to workout setup (also in edit mode)
        await context.push('/onboarding/workout-setup?edit=true');
      } else {
        // Normal onboarding flow
        await context.push('/onboarding/workout-setup');
      }
      if (mounted) setState(() => _isSaving = false);
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to save equipment right now. Please try again.',
            ),
          ),
        );
      }
    }
  }

  void _onTapChip(String label) async {
    if (label == 'See All Machines') {
      final result = await context.push<List<String>>(
        '/equipment/machines',
        extra: _selectedEquipment.toList(),
      );
      if (result != null && mounted) {
        setState(() {
          // Remove old machine selections
          _selectedEquipment.removeWhere((e) => _allMachineNames.contains(e));
          // Add new machine selections
          _selectedEquipment.addAll(result);
        });
      }
      return;
    }

    if (label == 'Add Custom') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custom equipment input is coming soon.')),
      );
      return;
    }

    setState(() {
      if (_selectedEquipment.contains(label)) {
        _selectedEquipment.remove(label);
      } else {
        _selectedEquipment.add(label);
      }
    });
  }

  void _onTapNoEquipment() {
    setState(() {
      _bodyweightSelected = !_bodyweightSelected;
    });
  }

  Future<void> _saveEquipmentToSupabase() async {
    final client = SupabaseBootstrap.client;
    final user = client?.auth.currentUser;

    if (client == null || user == null) {
      throw StateError('User is not authenticated.');
    }

    await client.from('user_equipment').upsert({
      'user_id': user.id,
      'equipment_list': _selectedEquipment.toList(),
      'has_bodyweight': _bodyweightSelected,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Future<void> _loadEquipmentFromSupabase() async {
    final client = SupabaseBootstrap.client;
    final user = client?.auth.currentUser;

    if (client == null || user == null) {
      return;
    }

    try {
      final row = await client
          .from('user_equipment')
          .select('equipment_list, has_bodyweight')
          .eq('user_id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 8), onTimeout: () => null);

      if (row == null || !mounted) {
        return;
      }

      final equipmentList = row['equipment_list'] as List<dynamic>?;
      final hasBodyweight = row['has_bodyweight'] as bool?;

      setState(() {
        if (equipmentList != null) {
          _selectedEquipment.clear();
          _selectedEquipment.addAll(equipmentList.map((e) => e.toString()));
        }

        if (hasBodyweight != null) {
          _bodyweightSelected = hasBodyweight;
        }
      });
    } catch (_) {
      // Fail silently for load - user can still select equipment
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode =
        GoRouterState.of(context).uri.queryParameters['edit'] == 'true';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            'PROGRESSIVE OVERLOAD',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.primary,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            AbsorbPointer(
              absorbing: _isSaving,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const OnboardingStepHeader(step: 2),
                      const SizedBox(height: 18),
                      Text(
                        'What equipment do you have?',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Select the gear you have access to so we can tailor your workout plan precisely.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: [
                            _ChipGroupCard(
                              icon: Icons.fitness_center,
                              title: 'Gym Equipment',
                              chips: _gymEquipment,
                              selectedChips: _selectedEquipment,
                              onTapChip: _onTapChip,
                            ),
                            const SizedBox(height: 12),
                            _ChipGroupCard(
                              icon: Icons.home,
                              title: 'Home / Minimal',
                              chips: _homeEquipment,
                              selectedChips: _selectedEquipment,
                              onTapChip: _onTapChip,
                            ),
                            const SizedBox(height: 12),
                            _NoEquipmentCard(
                              selected: _bodyweightSelected,
                              onTap: _onTapNoEquipment,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      NeonPrimaryButton(
                        label: isEditMode
                            ? 'Next: Update Workout'
                            : 'Next: Setup Workout',
                        icon: Icons.arrow_forward,
                        onPressed: () => _onContinue(isEditMode),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isSaving) const AppLoadingOverlay(),
          ],
        ),
      ),
    );
  }
}

class _ChipGroupCard extends StatelessWidget {
  const _ChipGroupCard({
    required this.icon,
    required this.title,
    required this.chips,
    required this.selectedChips,
    required this.onTapChip,
  });

  final IconData icon;
  final String title;
  final List<String> chips;
  final Set<String> selectedChips;
  final ValueChanged<String> onTapChip;

  @override
  Widget build(BuildContext context) {
    return KineticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips
                .map(
                  (chip) => chip == 'See All Machines'
                      ? Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => onTapChip(chip),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 9,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    chip,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.text,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 18,
                                    color: AppColors.text,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => onTapChip(chip),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                color: selectedChips.contains(chip)
                                    ? AppColors.primary.withValues(alpha: 0.15)
                                    : AppColors.surfaceLow,
                                border: Border.all(
                                  color: selectedChips.contains(chip)
                                      ? AppColors.primary
                                      : AppColors.outline.withValues(
                                          alpha: 0.4,
                                        ),
                                ),
                              ),
                              child: Text(
                                chip,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: selectedChips.contains(chip)
                                          ? AppColors.primary
                                          : AppColors.text,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ),
                        ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _NoEquipmentCard extends StatelessWidget {
  const _NoEquipmentCard({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return KineticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.accessibility_new, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Bodyweight Training',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.surfaceLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : AppColors.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  'Add bodyweight movements\n\nYou can combine this with your selected equipment.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
