import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class MessagingService {
  MessagingService(this._messaging);

  final FirebaseMessaging _messaging;

  static const topic = 'comp205';

  Future<String?> init() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final token = await _messaging.getToken();
      
      try {
        await _messaging.subscribeToTopic(topic);
      } catch (e) {
        debugPrint('Topic abonelik uyarisi: $e');
      }

      debugPrint('========================================');
      debugPrint('FCM token: $token');
      debugPrint('========================================');

      return token;
    } catch (e, stack) {
      debugPrint('FCM init hatasi: $e');
      debugPrint('Stack: $stack');
      return null;
    }
  }

  void listenInForeground(void Function(String title, String body) show) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'New message';
      final body = message.notification?.body ?? '';
      show(title, body);
    });
  }
}
