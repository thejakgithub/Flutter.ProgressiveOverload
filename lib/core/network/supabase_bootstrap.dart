import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

class SupabaseBootstrap {
  SupabaseBootstrap._();

  static const _url = String.fromEnvironment('SUPABASE_URL');
  static const _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool _initialized = false;
  static AppLinks? _appLinks;

  static bool get isConfigured => _url.isNotEmpty && _anonKey.isNotEmpty;

  static Future<void> initialize() async {
    if (_initialized || !isConfigured) return;

    await Supabase.initialize(url: _url, anonKey: _anonKey);

    _initialized = true;

    // Setup deep link listener for OAuth callbacks
    _setupDeepLinkListener();
  }

  static void _setupDeepLinkListener() {
    _appLinks = AppLinks();

    // Handle deep link when app is already running
    _appLinks!.uriLinkStream.listen((Uri uri) {
      _handleDeepLink(uri);
    });

    // Handle deep link when app starts from deep link
    _appLinks!.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  static Future<void> _handleDeepLink(Uri uri) async {
    // Supabase automatically handles auth callbacks through onAuthStateChange
    // No need to manually call getSessionFromUri in newer versions
    // The session will be automatically restored
  }

  static SupabaseClient? get client {
    if (!_initialized) return null;
    return Supabase.instance.client;
  }
}
