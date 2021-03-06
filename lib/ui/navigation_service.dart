import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/core/models/user.dart';
import 'package:flutter_firebase_template/ui/router.dart';
export 'package:flutter_firebase_template/ui/router.dart';

class NavigationService {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  NavigationService(Stream<User> userStream) {
    userStream.listen(returnToLoginView);
  }

  Future<dynamic> navigateTo(String routeName, {Object arguments}) =>
      _navigatorKey.currentState.pushNamed(routeName, arguments: arguments);

  Future<dynamic> pushReplacementNamed(String routeName) =>
      _navigatorKey.currentState.pushReplacementNamed(routeName);

  Future<dynamic> returnToLoginView(User user) {
    if (user == null) {
      return _navigatorKey.currentState
          .pushNamedAndRemoveUntil(Router.login, (Route route) => false);
    }
    return null;
  }

  Future<dynamic> returnToHomeView({Object arguments}) => _navigatorKey.currentState
      .pushNamedAndRemoveUntil(Router.home, (Route route) => false, arguments: arguments);

  bool pop([bool result]) => _navigatorKey.currentState.pop(result);

  void popUntilNamed(String routeName) {
    _navigatorKey.currentState.popUntil(ModalRoute.withName(routeName));
  }
}
