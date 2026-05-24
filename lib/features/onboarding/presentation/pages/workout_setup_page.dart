import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/po_widgets.dart';

class WorkoutSetupPage extends StatefulWidget {
  const WorkoutSetupPage({super.key});

  @override
  State<WorkoutSetupPage> createState() => _WorkoutSetupPageState();
}

class _WorkoutSetupPageState extends State<WorkoutSetupPage> {
  String? _selectedSetup = 'build_my_own';

  Future<void> _onContinue(bool isEditMode) async {
    if (_selectedSetup == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a workout setup option.')),
      );
      return;
    }

    // Only "Build My Own" is available for now
    if (_selectedSetup != 'build_my_own') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This feature is coming soon. Please select "Build My Own" for now.',
          ),
        ),
      );
      return;
    }

    if (!mounted) return;
    if (isEditMode) {
      // In edit mode, go to planner to review exercises
      context.push('/planner/weekly');
    } else {
      // Normal onboarding flow - go to planner
      context.push('/planner/weekly');
    }
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
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OnboardingStepHeader(step: 3),
                const SizedBox(height: 18),
                Text(
                  'Workout Setup',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'How would you like to train?',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Column(
                    children: [
                      _OptionCard(
                        selected: _selectedSetup == 'build_my_own',
                        onTap: () {
                          setState(() => _selectedSetup = 'build_my_own');
                        },
                        icon: Icons.edit_note,
                        title: 'Build My Own',
                        subtitle:
                            'Select exercises manually and create your custom routine.',
                      ),
                      const SizedBox(height: 12),
                      _OptionCard(
                        selected: _selectedSetup == 'ai_smart_routine',
                        onTap: () {
                          setState(() => _selectedSetup = 'ai_smart_routine');
                        },
                        icon: Icons.psychology,
                        title: 'AI Smart Routine',
                        subtitle:
                            'Let our AI suggest the best program based on your equipment and frequency.',
                      ),
                      const SizedBox(height: 12),
                      _OptionCard(
                        selected: _selectedSetup == 'explore_templates',
                        onTap: () {
                          setState(() => _selectedSetup = 'explore_templates');
                        },
                        icon: Icons.library_books,
                        title: 'Explore Templates',
                        subtitle: 'Choose from professional pre-made programs.',
                      ),
                    ],
                  ),
                ),
                NeonPrimaryButton(
                  label: isEditMode ? 'Next: Select Exercises' : 'Continue',
                  icon: Icons.arrow_forward,
                  onPressed: () => _onContinue(isEditMode),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
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
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : AppColors.outline.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : AppColors.surfaceHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: selected ? const Color(0xFF121415) : AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
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
