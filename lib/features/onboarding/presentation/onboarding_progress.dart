import '../../../core/network/supabase_bootstrap.dart';

class OnboardingProgress {
  OnboardingProgress._();

  // Check if user has completed step 1 (vitals)
  static Future<bool> isStep1Done() async {
    try {
      final userId = SupabaseBootstrap.client?.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await SupabaseBootstrap.client!
          .from('user_vitals')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 3));

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Check if user has completed step 2 (equipment)
  static Future<bool> isStep2Done() async {
    try {
      final userId = SupabaseBootstrap.client?.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await SupabaseBootstrap.client!
          .from('user_equipment')
          .select('user_id')
          .eq('user_id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 3));

      return response != null;
    } catch (e) {
      return false;
    }
  }

  // Check if user has completed step 3 (weekly plan)
  static Future<bool> isStep3Done() async {
    return isCompleted();
  }

  // Check if onboarding is completed (has weekly plan)
  static Future<bool> isCompleted() async {
    try {
      final userId = SupabaseBootstrap.client?.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await SupabaseBootstrap.client!
          .from('user_weekly_plan')
          .select('is_completed')
          .eq('user_id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 3));

      return response?['is_completed'] == true;
    } catch (e) {
      return false;
    }
  }
}
