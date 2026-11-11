import 'package:flutter/widgets.dart';

import 'auth_repository.dart';
import 'auth_state.dart';

class MadadAppScope extends InheritedWidget {
  const MadadAppScope({
    required this.auth,
    required this.repository,
    required super.child,
    super.key,
  });

  final AuthState auth;
  final AuthRepository repository;

  static MadadAppScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MadadAppScope>()!;

  @override
  bool updateShouldNotify(MadadAppScope oldWidget) =>
      auth != oldWidget.auth || repository != oldWidget.repository;
}
