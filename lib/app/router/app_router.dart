import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/supabase_bootstrap.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/equipment/presentation/pages/equipment_selection_page.dart';
import '../../features/machines/presentation/pages/browse_machines_page.dart';
import '../../features/onboarding/presentation/onboarding_progress.dart';
import '../../features/onboarding/presentation/pages/onboarding_vitals_page.dart';
import '../../features/onboarding/presentation/pages/workout_setup_page.dart';
import '../../features/planner/presentation/pages/weekly_planner_day_popup_page.dart';
import '../../features/planner/presentation/pages/weekly_planner_options_popup_page.dart';
import '../../features/planner/presentation/pages/weekly_planner_page.dart';
import '../widgets/main_shell_page.dart';
import '../../features/workout/presentation/pages/add_exercise_page.dart';
import '../../features/workout/presentation/pages/edit_exercise_page.dart';

class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier() {
    _subscription = SupabaseBootstrap.client?.auth.onAuthStateChange.listen((
      _,
    ) {
      notifyListeners();
    });
  }

  StreamSubscription<dynamic>? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

class AppRouter {
  AppRouter._();

  static final _authNotifier = _AuthRefreshNotifier();

  // Temporary testing switch:
  // true  -> always enter onboarding after login
  // false -> use normal production behavior
  static const _forceOnboardingAfterLoginForTesting = false;

  static bool get _isAuthenticated =>
      SupabaseBootstrap.client?.auth.currentSession != null;

  static bool _isProtectedPath(String path) {
    return path.startsWith('/workout') ||
        path.startsWith('/planner') ||
        path.startsWith('/profile') ||
        path.startsWith('/equipment') ||
        path.startsWith('/onboarding');
  }

  static final GoRouter router = GoRouter(
    refreshListenable: _authNotifier,
    redirect: (context, state) async {
      final path = state.uri.path;
      final inAuth = path.startsWith('/auth/');
      final inResetPassword = path == '/auth/reset-password';
      final inOnboarding =
          path.startsWith('/onboarding') ||
          path.startsWith('/equipment') ||
          path == '/planner/weekly' ||
          path == '/workout/add';
      final isEditMode = state.uri.queryParameters['edit'] == 'true';
      final loggedIn = _isAuthenticated;
      final onboardingDone = await OnboardingProgress.isCompleted();
      final step1Done = await OnboardingProgress.isStep1Done();
      final step2Done = await OnboardingProgress.isStep2Done();

      if (!loggedIn && _isProtectedPath(path)) {
        return '/auth/login';
      }

      // ===== ONBOARDING TEST MODE (temporary) =====
      // Force users to land on onboarding after login,
      // even when onboarding was already completed.
      if (_forceOnboardingAfterLoginForTesting && loggedIn) {
        if ((inAuth && !inResetPassword) ||
            path == '/' ||
            (!inOnboarding && _isProtectedPath(path))) {
          return '/onboarding/vitals';
        }
      }
      // ===== END ONBOARDING TEST MODE =====

      if (loggedIn && !onboardingDone) {
        if (path == '/onboarding/workout-setup' && !step2Done) {
          return step1Done ? '/equipment/selection' : '/onboarding/vitals';
        }

        if (path.startsWith('/equipment') && !step1Done) {
          return '/onboarding/vitals';
        }

        // Allow /planner/weekly only after step 1 and 2 are done
        if (path == '/planner/weekly' && (!step1Done || !step2Done)) {
          return step1Done ? '/equipment/selection' : '/onboarding/vitals';
        }

        if ((inAuth && !inResetPassword) ||
            path == '/' ||
            (!inOnboarding && _isProtectedPath(path))) {
          return '/onboarding/vitals';
        }
      }

      if (loggedIn && onboardingDone && !_forceOnboardingAfterLoginForTesting) {
        // Allow access to onboarding pages in edit mode
        if (inOnboarding && isEditMode) {
          return null;
        }

        if ((inAuth && !inResetPassword) ||
            path == '/' ||
            (inOnboarding && path != '/workout/add')) {
          return '/workout/daily';
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/auth/reset-password',
        builder: (context, state) => const ResetPasswordPage(),
      ),
      GoRoute(
        path: '/onboarding/vitals',
        builder: (context, state) => const OnboardingVitalsPage(),
      ),
      GoRoute(
        path: '/onboarding/workout-setup',
        builder: (context, state) => const WorkoutSetupPage(),
      ),
      GoRoute(
        path: '/equipment/selection',
        builder: (context, state) => const EquipmentSelectionPage(),
      ),
      GoRoute(
        path: '/equipment/machines',
        builder: (context, state) => const BrowseMachinesPage(),
      ),
      GoRoute(
        path: '/workout/daily',
        builder: (context, state) => const MainShellPage(),
      ),
      GoRoute(
        path: '/workout/add',
        builder: (context, state) {
          final extra = state.extra;
          final day = extra is (String, String?) ? extra.$1 : extra as String?;
          final templateName = extra is (String, String?) ? extra.$2 : null;
          return AddExercisePage(day: day, templateName: templateName);
        },
      ),
      GoRoute(
        path: '/workout/edit',
        builder: (context, state) => const EditExercisePage(),
      ),
      GoRoute(
        path: '/planner/weekly',
        builder: (context, state) => const WeeklyPlannerPage(),
      ),
      GoRoute(
        path: '/planner/day-popup',
        builder: (context, state) => const WeeklyPlannerDayPopupPage(),
      ),
      GoRoute(
        path: '/planner/options-popup',
        builder: (context, state) => const WeeklyPlannerOptionsPopupPage(),
      ),
      GoRoute(
        path: '/profile/dashboard',
        builder: (context, state) => const MainShellPage(initialIndex: 1),
      ),
    ],
  );
}
