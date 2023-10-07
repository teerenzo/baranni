import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/storage/local_storage.dart';
import 'package:barrani/helpers/theme/admin_theme.dart';
import 'package:barrani/helpers/theme/app_theme.dart';

//
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themesProvider = StateNotifierProvider<ThemesProvider, ThemeMode?>((_) {
  return ThemesProvider();
});

class _ThemeState {
  bool leftBarCondensed;

  _ThemeState({
    this.leftBarCondensed = false,
  });

  _ThemeState copyWith({
    bool? leftBarCondensed,
  }) {
    return _ThemeState(
      leftBarCondensed: leftBarCondensed ?? this.leftBarCondensed,
    );
  }
}

class ThemeNotifier extends StateNotifier<_ThemeState> {
  final Ref ref;
  ThemeNotifier({
    required this.ref,
  }) : super(_ThemeState());

  void toggleLeftBarCondensed() {
    print('object ${state.leftBarCondensed}');
    state = state.copyWith(leftBarCondensed: !state.leftBarCondensed);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, _ThemeState>(
  (ref) => ThemeNotifier(ref: ref),
);

class ThemesProvider extends StateNotifier<ThemeMode?> {
  ThemesProvider() : super(ThemeMode.system) {
    _initializeTheme();
  }

  void _initializeTheme() async {
    bool isOn = LocalStorage.getAppTheme();
    changeTheme(isOn);
  }

  void changeTheme(bool isOn) {
    AdminTheme.setTheme(isOn);
    theme = isOn ? AppTheme.darkTheme : AppTheme.lightTheme;
    state = isOn ? ThemeMode.dark : ThemeMode.light;
    LocalStorage.setAppTheme(isOn);
  }
}
