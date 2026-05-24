import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/po_widgets.dart';
import '../../../auth/presentation/providers/auth_controller.dart';

class ProfileDashboardPage extends StatefulWidget {
  const ProfileDashboardPage({super.key});

  @override
  State<ProfileDashboardPage> createState() => _ProfileDashboardPageState();
}

class _ProfileDashboardPageState extends State<ProfileDashboardPage> {
  final _authController = AuthController.create();
  bool _signingOut = false;

  Future<void> _onLogout() async {
    if (_signingOut) {
      return;
    }

    setState(() => _signingOut = true);
    try {
      await _authController.signOut();
      if (!mounted) {
        return;
      }
      context.go('/auth/login');
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) {
        setState(() => _signingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const AppHeaderLogo(), centerTitle: true),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.25),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 56,
                        backgroundColor: AppColors.surfaceContainer,
                        child: Icon(
                          Icons.person,
                          size: 64,
                          color: Colors.white54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'John Doe',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: AppColors.primary.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Text(
                        'ELITE MEMBER',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              letterSpacing: 3,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              KineticCard(
                child: Row(
                  children: const [
                    _Metric(label: 'HEIGHT', value: '180', unit: 'cm'),
                    _Metric(label: 'WEIGHT', value: '82', unit: 'kg'),
                    _Metric(label: 'AGE', value: '28', unit: 'yrs'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: _StatsTile(
                      icon: Icons.local_fire_department,
                      title: 'ENERGY\nEXPENDITURE',
                      value: '2,850 kcal/day',
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _StatsTile(
                      icon: Icons.fitness_center,
                      title: 'TRAINING PLAN',
                      value: 'Hypertrophy Block\nWk 4 of 8 • 4 days/wk',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              KineticCard(
                child: Column(
                  children: [
                    const _ListRow(
                      icon: Icons.history,
                      label: 'Workout History',
                    ),
                    const Divider(color: AppColors.outline),
                    const _ListRow(
                      icon: Icons.emoji_events,
                      label: 'Personal Records',
                    ),
                    const Divider(color: AppColors.outline),
                    _ListRow(
                      icon: Icons.refresh,
                      label: 'Update Workout Program',
                      onTap: () => context.push('/onboarding/vitals?edit=true'),
                    ),
                    const Divider(color: AppColors.outline),
                    const _ListRow(icon: Icons.settings, label: 'Settings'),
                    const Divider(color: AppColors.outline),
                    const _ListRow(icon: Icons.support_agent, label: 'Support'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(58),
                  foregroundColor: const Color(0xFFF5AFA8),
                  side: const BorderSide(color: Color(0x55F5AFA8)),
                ),
                onPressed: _signingOut ? null : _onLogout,
                icon: const Icon(Icons.logout),
                label: Text(_signingOut ? 'LOGGING OUT...' : 'LOG OUT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, required this.unit});

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              text: value,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.primary),
              children: [
                TextSpan(
                  text: ' $unit',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsTile extends StatelessWidget {
  const _StatsTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return KineticCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _ListRow extends StatelessWidget {
  const _ListRow({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleLarge),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
