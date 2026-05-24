import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NeonPrimaryButton extends StatelessWidget {
  const NeonPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expanded = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final child = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: const Color(0xFF161E00),
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
          Text(label),
        ],
      ),
    );

    if (!expanded) return child;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(171, 214, 0, 0.28),
            blurRadius: 18,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.label, {super.key, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (trailing is Widget) trailing!,
      ],
    );
  }
}

class KineticCard extends StatelessWidget {
  const KineticCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.7)),
      ),
      child: child,
    );
  }
}

/// Full-screen loading overlay — use inside a Stack above the main content.
class AppLoadingOverlay extends StatelessWidget {
  const AppLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.5),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

/// App logo block shown on auth screens (bolt icon in a white rounded box).
class AppLogoBlock extends StatelessWidget {
  const AppLogoBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 22,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.85)),
        ),
        child: const Center(
          child: Icon(Icons.bolt, color: AppColors.primary, size: 52),
        ),
      ),
    );
  }
}

/// AppBar title widget showing bolt icon + "PROGRESSIVE\nOVERLOAD" text.
class AppHeaderLogo extends StatelessWidget {
  const AppHeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: AppColors.surfaceContainer,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
          ),
          child: const Icon(Icons.bolt, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 8),
        Text(
          'PROGRESSIVE\nOVERLOAD',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: AppColors.primary),
        ),
      ],
    );
  }
}

/// Onboarding step progress header — "Step N of [total]" + progress bar dots.
class OnboardingStepHeader extends StatelessWidget {
  const OnboardingStepHeader({
    super.key,
    required this.step,
    this.totalSteps = 3,
  });

  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Step $step of $totalSteps',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        for (int i = 1; i <= totalSteps; i++)
          _OnboardingProgressDot(active: step >= i),
      ],
    );
  }
}

class _OnboardingProgressDot extends StatelessWidget {
  const _OnboardingProgressDot({this.active = false});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 6),
      width: 34,
      height: 4,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.surfaceHighest,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
