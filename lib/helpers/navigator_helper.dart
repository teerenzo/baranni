import 'package:flutter/material.dart';
import 'package:one_context/one_context.dart';

abstract class NavigatorHelper {
  static pop() => OneContext().pop();

  static popTwice() {
    OneContext().pop();
    OneContext().pop();
  }

  static popMultiple(int count) =>
      List.generate(count, (_) => OneContext().pop());

  static popUntilNamed(String routeName) => OneContext().popUntil(
        ModalRoute.withName(routeName),
      );

  static pushNamedAndRemoveUntil(String routeName, String oldRouteName) =>
      OneContext().pushNamedAndRemoveUntil(
        routeName,
        ModalRoute.withName(oldRouteName),
      );

  static Future pushNamed(String routeName, {Object? arguments}) =>
      OneContext().pushNamed(routeName, arguments: arguments);

  static Future pushReplacementNamed(String routeName, {Object? arguments}) =>
      OneContext().pushReplacementNamed(routeName, arguments: arguments);

  static Future pushNamedAndRemoveAll(String routeName, {Object? arguments}) {
    return OneContext().pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static Future pushNamedAndRemoveUntilFirst(
    String routeName, {
    Object? arguments,
  }) {
    return OneContext().pushNamedAndRemoveUntil(
      routeName,
      (route) => route.isFirst,
      arguments: arguments,
    );
  }

  static popUntilFirst() => OneContext().popUntil((route) => route.isFirst);

  static Future pushNamedAndRemoveNumberOfRoutes(
    String routeName, {
    required int numberOfRoutes,
    Object? arguments,
  }) {
    int count = 0;

    return OneContext().pushNamedAndRemoveUntil(
      routeName,
      (route) {
        count++;
        return count == numberOfRoutes;
      },
      arguments: arguments,
    );
  }
}
