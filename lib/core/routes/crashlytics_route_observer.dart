import 'package:flutter/material.dart';
import 'package:fitzee_new/core/services/crashlytics_service.dart';

/// Reports the current route/screen to Crashlytics when navigation changes.
class CrashlyticsRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _setScreen(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) _setScreen(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) _setScreen(newRoute);
  }

  void _setScreen(Route<dynamic> route) {
    final name = route.settings.name ?? route.settings.arguments?.toString() ?? 'unknown';
    CrashlyticsService.setScreen(name);
  }
}
