import 'package:flutter/material.dart';

import '../features/home/home.dart';

class AppRouteObservers {
  AppRouteObservers._();

  static final AppRouteStackObserver stackObserver = AppRouteStackObserver();

  static List<NavigatorObserver> get all => [
    // Global observer
    stackObserver,

    // Page-specific observers
    HomeView.routeObserver
  ];
}

class AppRouteStackObserver extends NavigatorObserver {
  final List<Route<dynamic>> _routeStack = [];

  List<String> get routeNames => _routeStack
      .map((route) => route.settings.name)
      .whereType<String>()
      .toList(growable: false);

  String? get currentRoute => routeNames.lastOrNull;

  List<String> get previousRoutes {
    final routes = routeNames;

    if (routes.length <= 1) {
      return const [];
    }

    return routes.sublist(0, routes.length - 1);
  }

  @override
  void didPush(
      Route<dynamic> route,
      Route<dynamic>? previousRoute,
      ) {
    _routeStack.add(route);

    super.didPush(route, previousRoute);
  }

  @override
  void didPop(
      Route<dynamic> route,
      Route<dynamic>? previousRoute,
      ) {
    _routeStack.remove(route);

    super.didPop(route, previousRoute);
  }

  @override
  void didRemove(
      Route<dynamic> route,
      Route<dynamic>? previousRoute,
      ) {
    _routeStack.remove(route);

    super.didRemove(route, previousRoute);
  }

  @override
  void didReplace({
    Route<dynamic>? newRoute,
    Route<dynamic>? oldRoute,
  }) {
    if (oldRoute != null) {
      final index = _routeStack.indexOf(oldRoute);

      if (index != -1) {
        if (newRoute != null) {
          _routeStack[index] = newRoute;
        } else {
          _routeStack.removeAt(index);
        }
      }
    } else if (newRoute != null) {
      _routeStack.add(newRoute);
    }

    super.didReplace(
      newRoute: newRoute,
      oldRoute: oldRoute,
    );
  }
}