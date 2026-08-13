import 'dart:async';
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';

class DeepLinkHandler {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  /// تهيئة وتتبع الـ Deep Links
  Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
    // 1️⃣ التعامل مع الرابط عند فتح التطبيق المغلق (Initial Link)
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri, navigatorKey);
      }
    } catch (e) {
      debugPrint('Failed to get initial deep link: $e');
    }

    // 2️⃣ الاستماع للروابط المباشرة أثناء عمل التطبيق (Background / Foreground)
    _sub = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleUri(uri, navigatorKey);
      },
      onError: (err) {
        debugPrint('Deep link stream error: $err');
      },
    );
  }

  /// معالجة الرابط والتقاط البيانات (مثل كود المسابقة أو ID المسابقة)
  void _handleUri(Uri uri, GlobalKey<NavigatorState> navigatorKey) {
    debugPrint('🔗 Received Deep Link: $uri');

    // مثال لفك تشفير الرابط: ptook://competition?id=123 أو https://ptook.app/competition/123
    final path = uri.path;
    final queryParams = uri.queryParameters;

    if (uri.host == 'competition' || path.contains('/competition')) {
      final competitionId = queryParams['id'] ?? (uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null);

      if (competitionId != null) {
        // التنقل إلى شاشة تفاصيل المسابقة مباشرة عبر navigatorKey
        // navigatorKey.currentState?.pushNamed('/competition-details', arguments: competitionId);
      }
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}