import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../network/supabase_bootstrap.dart';
import 'local_notification_service.dart';

class PushNotificationService {
  PushNotificationService._();

  static const _pushEnabled =
      String.fromEnvironment('ENABLE_FIREBASE_PUSH', defaultValue: 'false') ==
      'true';

  static bool _initialized = false;

  static bool get isEnabled => _pushEnabled;

  static Future<void> initialize() async {
    if (_initialized || !_pushEnabled) {
      return;
    }

    await Firebase.initializeApp();

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title;
      final body = message.notification?.body;

      if (title == null && body == null) {
        return;
      }

      LocalNotificationService.showMessage(
        title: title ?? 'Progressive Overload',
        body: body ?? 'You have a new notification.',
      );
    });

    messaging.onTokenRefresh.listen((token) {
      unawaited(_saveTokenToSupabase(token));
    });

    final initialToken = await _safeGetFcmToken(messaging);
    if (initialToken != null && initialToken.isNotEmpty) {
      await _saveTokenToSupabase(initialToken);
    }

    _initialized = true;
  }

  static Future<void> syncCurrentDeviceToken() async {
    if (!_pushEnabled) {
      throw StateError(
        'Firebase push is disabled. Set ENABLE_FIREBASE_PUSH=true.',
      );
    }

    if (!_initialized) {
      await initialize();
    }

    final token = await _safeGetFcmToken(FirebaseMessaging.instance);
    if (token == null || token.isEmpty) {
      throw StateError(
        'FCM token is not ready yet. Open app permissions and try Sync Push Token again.',
      );
    }

    await _saveTokenToSupabase(token);
  }

  static Future<void> _saveTokenToSupabase(String token) async {
    final client = SupabaseBootstrap.client;
    final user = client?.auth.currentUser;
    if (client == null || user == null) {
      return;
    }

    await client.from('device_push_tokens').upsert({
      'user_id': user.id,
      'fcm_token': token,
      'platform': _platformLabel(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'user_id,fcm_token');
  }

  static Future<String?> _safeGetFcmToken(FirebaseMessaging messaging) async {
    try {
      return await messaging.getToken();
    } on FirebaseException catch (error) {
      if (error.code == 'apns-token-not-set') {
        return null;
      }
      rethrow;
    } on PlatformException catch (error) {
      if (error.code == 'firebase_messaging/apns-token-not-set') {
        return null;
      }
      rethrow;
    }
  }

  static String _platformLabel() {
    if (kIsWeb) {
      return 'web';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    }
    if (defaultTargetPlatform == TargetPlatform.macOS) {
      return 'macos';
    }
    return 'unknown';
  }
}
