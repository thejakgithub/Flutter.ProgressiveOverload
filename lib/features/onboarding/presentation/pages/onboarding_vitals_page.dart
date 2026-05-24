import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/supabase_bootstrap.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/po_widgets.dart';

class OnboardingVitalsPage extends StatefulWidget {
  const OnboardingVitalsPage({super.key});

  @override
  State<OnboardingVitalsPage> createState() => _OnboardingVitalsPageState();
}

class _OnboardingVitalsPageState extends State<OnboardingVitalsPage> {
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedGoal = 'Muscle Gain';
  int _selectedDaysPerWeek = 4;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadVitalsFromSupabase();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode =
        GoRouterState.of(context).uri.queryParameters['edit'] == 'true';

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'PROGRESSIVE OVERLOAD',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: AppColors.primary,
            ),
          ),
          centerTitle: true,
          leading: isEditMode
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.pop(),
                )
              : null,
        ),
        body: Stack(
          children: [
            AbsorbPointer(
              absorbing: _isSaving,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const OnboardingStepHeader(step: 1),
                      const SizedBox(height: 18),
                      Text(
                        'Your Baseline',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We need a few details to calculate your daily energy expenditure accurately.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Expanded(
                        child: ListView(
                          children: [
                            _VitalsCard(
                              selectedGender: _selectedGender,
                              ageController: _ageController,
                              heightController: _heightController,
                              weightController: _weightController,
                              onSelectGender: (value) {
                                setState(() => _selectedGender = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            _FitnessGoalCard(
                              selectedGoal: _selectedGoal,
                              onSelectGoal: (value) {
                                setState(() => _selectedGoal = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            _TrainingFrequencyCard(
                              selectedDay: _selectedDaysPerWeek,
                              onSelectDay: (value) {
                                setState(() => _selectedDaysPerWeek = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            NeonPrimaryButton(
                              label: isEditMode
                                  ? 'Next: Update Equipment'
                                  : 'Calculate TDEE',
                              icon: Icons.arrow_forward,
                              onPressed: () async {
                                if (!_validateBeforeContinue()) {
                                  return;
                                }

                                final age = int.parse(
                                  _ageController.text.trim(),
                                );
                                final height = double.parse(
                                  _heightController.text.trim(),
                                );
                                final weight = double.parse(
                                  _weightController.text.trim(),
                                );

                                setState(() => _isSaving = true);
                                try {
                                  await _saveVitalsToSupabase(
                                    age: age,
                                    heightCm: height,
                                    weightKg: weight,
                                  );

                                  if (!context.mounted) {
                                    return;
                                  }

                                  if (isEditMode) {
                                    await context.push(
                                      '/equipment/selection?edit=true',
                                    );
                                  } else {
                                    await context.push('/equipment/selection');
                                  }
                                  if (mounted) {
                                    setState(() => _isSaving = false);
                                  }
                                } catch (_) {
                                  if (mounted) {
                                    setState(() => _isSaving = false);
                                    _showValidationMessage(
                                      'Unable to save your vitals right now. Please try again.',
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
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

  bool _validateBeforeContinue() {
    final ageText = _ageController.text.trim();
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();

    if (ageText.isEmpty || heightText.isEmpty || weightText.isEmpty) {
      _showValidationMessage('Please complete age, height, and weight.');
      return false;
    }

    final age = int.tryParse(ageText);
    final height = double.tryParse(heightText);
    final weight = double.tryParse(weightText);

    if (age == null || height == null || weight == null) {
      _showValidationMessage('Age, height, and weight must be numeric values.');
      return false;
    }

    if (age <= 0 || height <= 0 || weight <= 0) {
      _showValidationMessage('Age, height, and weight must be greater than 0.');
      return false;
    }

    FocusScope.of(context).unfocus();
    return true;
  }

  void _showValidationMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveVitalsToSupabase({
    required int age,
    required double heightCm,
    required double weightKg,
  }) async {
    final client = SupabaseBootstrap.client;
    final user = client?.auth.currentUser;

    if (client == null || user == null) {
      throw StateError('User is not authenticated.');
    }

    await client.from('user_vitals').upsert({
      'user_id': user.id,
      'gender': _selectedGender,
      'age': age,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'fitness_goal': _selectedGoal,
      'training_days_per_week': _selectedDaysPerWeek,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id');
  }

  Future<void> _loadVitalsFromSupabase() async {
    final client = SupabaseBootstrap.client;
    final user = client?.auth.currentUser;

    if (client == null || user == null) {
      return;
    }

    try {
      final row = await client
          .from('user_vitals')
          .select(
            'gender, age, height_cm, weight_kg, fitness_goal, training_days_per_week',
          )
          .eq('user_id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 8), onTimeout: () => null);

      if (row == null || !mounted) {
        return;
      }

      final gender = row['gender'] as String?;
      final goal = row['fitness_goal'] as String?;
      final age = row['age'];
      final heightCm = row['height_cm'];
      final weightKg = row['weight_kg'];
      final trainingDays = row['training_days_per_week'];

      setState(() {
        if (gender == 'Male' || gender == 'Female' || gender == 'Other') {
          _selectedGender = gender!;
        }

        if (goal == 'Strength' || goal == 'Muscle Gain' || goal == 'Fat Loss') {
          _selectedGoal = goal!;
        }

        if (age is num && _ageController.text.trim().isEmpty) {
          _ageController.text = age.toInt().toString();
        }

        if (heightCm is num && _heightController.text.trim().isEmpty) {
          _heightController.text = _formatDecimal(heightCm.toDouble());
        }

        if (weightKg is num && _weightController.text.trim().isEmpty) {
          _weightController.text = _formatDecimal(weightKg.toDouble());
        }

        if (trainingDays is num) {
          final day = trainingDays.toInt();
          if (day >= 1 && day <= 7) {
            _selectedDaysPerWeek = day;
          }
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showValidationMessage('Unable to load your saved vitals.');
    } finally {
      // No UI lock is tied to loading state now.
    }
  }

  String _formatDecimal(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString();
  }
}

class _VitalsCard extends StatelessWidget {
  const _VitalsCard({
    required this.selectedGender,
    required this.ageController,
    required this.heightController,
    required this.weightController,
    required this.onSelectGender,
  });

  final String selectedGender;
  final TextEditingController ageController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final ValueChanged<String> onSelectGender;

  @override
  Widget build(BuildContext context) {
    return KineticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(icon: Icons.person, title: 'Vitals'),
          const SizedBox(height: 10),
          Text(
            'Gender',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _Pill(
                  label: 'Male',
                  selected: selectedGender == 'Male',
                  onTap: () => onSelectGender('Male'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Pill(
                  label: 'Female',
                  selected: selectedGender == 'Female',
                  onTap: () => onSelectGender('Female'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _Pill(
                  label: 'Other',
                  selected: selectedGender == 'Other',
                  onTap: () => onSelectGender('Other'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InputField(
            label: 'Age',
            hintText: 'Enter age',
            controller: ageController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _InputField(
                  label: 'Height (cm)',
                  hintText: 'Enter height',
                  controller: heightController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InputField(
                  label: 'Weight (kg)',
                  hintText: 'Enter weight',
                  controller: weightController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FitnessGoalCard extends StatelessWidget {
  const _FitnessGoalCard({
    required this.selectedGoal,
    required this.onSelectGoal,
  });

  final String selectedGoal;
  final ValueChanged<String> onSelectGoal;

  @override
  Widget build(BuildContext context) {
    return KineticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(icon: Icons.adjust, title: 'Fitness Goal'),
          const SizedBox(height: 10),
          _GoalTile(
            icon: Icons.fitness_center,
            title: 'Strength',
            subtitle: 'Focus on lifting heavier weights.',
            selected: selectedGoal == 'Strength',
            onTap: () => onSelectGoal('Strength'),
          ),
          const SizedBox(height: 10),
          _GoalTile(
            icon: Icons.accessibility_new,
            title: 'Muscle Gain',
            subtitle: 'Focus on hypertrophy and building size.',
            selected: selectedGoal == 'Muscle Gain',
            onTap: () => onSelectGoal('Muscle Gain'),
          ),
          const SizedBox(height: 10),
          _GoalTile(
            icon: Icons.local_fire_department,
            title: 'Fat Loss',
            subtitle: 'Focus on calorie deficit and definition.',
            selected: selectedGoal == 'Fat Loss',
            onTap: () => onSelectGoal('Fat Loss'),
          ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  const _GoalTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected ? null : AppColors.surfaceLow,
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0x364B5A2B), Color(0x1F6D7D3D)],
                  )
                : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.outline.withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.textMuted, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrainingFrequencyCard extends StatelessWidget {
  const _TrainingFrequencyCard({
    required this.selectedDay,
    required this.onSelectDay,
  });

  final int selectedDay;
  final ValueChanged<int> onSelectDay;

  @override
  Widget build(BuildContext context) {
    return KineticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardHeader(
            icon: Icons.fitness_center,
            title: 'Training Frequency',
          ),
          const SizedBox(height: 14),
          Text(
            'Days per week',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _FrequencyChip(
                day: 1,
                selected: selectedDay == 1,
                onTap: () => onSelectDay(1),
              ),
              _FrequencyChip(
                day: 2,
                selected: selectedDay == 2,
                onTap: () => onSelectDay(2),
              ),
              _FrequencyChip(
                day: 3,
                selected: selectedDay == 3,
                onTap: () => onSelectDay(3),
              ),
              _FrequencyChip(
                day: 4,
                selected: selectedDay == 4,
                onTap: () => onSelectDay(4),
              ),
              _FrequencyChip(
                day: 5,
                selected: selectedDay == 5,
                onTap: () => onSelectDay(5),
              ),
              _FrequencyChip(
                day: 6,
                selected: selectedDay == 6,
                onTap: () => onSelectDay(6),
              ),
              _FrequencyChip(
                day: 7,
                selected: selectedDay == 7,
                onTap: () => onSelectDay(7),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FrequencyChip extends StatelessWidget {
  const _FrequencyChip({
    required this.day,
    required this.onTap,
    this.selected = false,
  });

  final int day;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Center(
            child: Text(
              '$day',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: selected ? AppColors.primary : AppColors.text,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: Theme.of(context).textTheme.titleLarge,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textMuted.withValues(alpha: 0.75),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.outline.withValues(alpha: 0.4),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: selected ? AppColors.primary : AppColors.text,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}
