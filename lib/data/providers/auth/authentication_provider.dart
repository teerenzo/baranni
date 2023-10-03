import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/helpers/services/auth_services.dart';
import 'package:barrani/helpers/services/web_auth_services.dart';
import 'package:barrani/helpers/widgets/my_form_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class _AuthState {
  MyFormValidator basicValidator = MyFormValidator();

  bool showPassword;
  bool loading;
  bool isChecked;
  bool openMenu;
  var errors = {};

  _AuthState({
    this.showPassword = false,
    this.loading = false,
    this.isChecked = false,
    this.openMenu = false,
    this.errors = const {},
    MyFormValidator? basicValidator,
  });

  void init() {}

  _AuthState copyWith({
    MyFormValidator? basicValidator,
    bool? showPassword,
    bool? loading,
    bool? isChecked,
    bool? openMenu,
    var errors,
  }) {
    return _AuthState(
      basicValidator: basicValidator ?? this.basicValidator,
      showPassword: showPassword ?? this.showPassword,
      loading: loading ?? this.loading,
      isChecked: isChecked ?? this.isChecked,
      openMenu: openMenu ?? this.openMenu,
      errors: errors ?? this.errors,
    );
  }
}

class _AuthNotifier extends StateNotifier<_AuthState> {
  final Ref ref;
  _AuthNotifier({
    required this.ref,
  }) : super(_AuthState());

  void onChangeShowPassword() {
    state = state.copyWith(showPassword: !state.showPassword);
  }

  void onChangeCheckBox(bool? value) {
    state = state.copyWith(isChecked: value ?? state.isChecked);
  }

  String? getError(String name) {
    if (state.errors.containsKey(name)) {
      dynamic error = state.errors[name];

      String errorText = error.toString();

      return errorText;
    }
    return null;
  }

  Future<void> onLogin({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(loading: true);

    if (email.isEmpty || password.isEmpty) {
      var errors = {};
      if (email.isEmpty) {
        errors['email_error'] = 'Email is required';
        state = state.copyWith(errors: errors);
      } else {
        state = state.copyWith(loading: false);
        // check if email_error is in errors

        if (state.errors.containsKey('email_error')) {
          state = state.copyWith(errors: state.errors..remove('email_error'));
        }
      }

      if (password.isEmpty) {
        errors['password_error'] = 'Password is required';
        state = state.copyWith(errors: errors);
      } else {
        state = state.copyWith(loading: false);
        if (state.errors.containsKey('password_error')) {
          state =
              state.copyWith(errors: state.errors..remove('password_error'));
        }
      }

      state = state.copyWith(loading: false);

      return;
    }

    var errors = kIsWeb
        ? await WebAuthService.loginUser({
            'email': email,
            'password': password,
          })
        : await AuthService.loginUser({'email': email, 'password': password});
    if (errors != null) {
      var error = {'error': 'Email or password is incorrect'};
      state = state.copyWith(errors: error);
      state.basicValidator.addErrors(error);
      state.basicValidator.validateForm();
      state.basicValidator.clearErrors();
    } else {
      state = state.copyWith(errors: {});
      NavigatorHelper.pushNamed('/dashboard');
    }
    state = state.copyWith(loading: false);
  }

  Future<void> onRegister(
      {required String email,
      required String password,
      required String invitationCode}) async {
    state = state.copyWith(loading: true);

    if (email.isEmpty || password.isEmpty || invitationCode.isEmpty) {
      if (email.isEmpty) {
        state = state.copyWith(
            errors: state.errors..addAll({'email_error': 'Email is required'}));
      } else {
        state = state.copyWith(errors: state.errors..remove('email_error'));
      }

      if (password.isEmpty) {
        state = state.copyWith(
            errors: state.errors
              ..addAll({'password_error': 'Password is required'}));
      } else {
        state = state.copyWith(errors: state.errors..remove('password_error'));
      }

      if (invitationCode.isEmpty) {
        state = state.copyWith(
            errors: state.errors
              ..addAll(
                  {'invitation_code_error': 'Invitation code is required'}));
      } else {
        state = state.copyWith(
            errors: state.errors..remove('invitation_code_error'));
      }

      state = state.copyWith(loading: false);

      return;
    }

    var errors = kIsWeb
        ? await WebAuthService.registerUser({
            'email': email,
            'password': password,
            'invitationCode': invitationCode,
          })
        : await AuthService.registerUser({
            'email': email,
            'password': password,
            'invitationCode': invitationCode,
          });
    if (errors != null) {
      state.basicValidator.addErrors(errors);
      state.basicValidator.validateForm();
      state.basicValidator.clearErrors();
      state = state.copyWith(errors: errors);
    } else {
      state = state.copyWith(errors: {});
      NavigatorHelper.pushNamed('/auth/login');
    }
    state = state.copyWith(loading: false);
  }

  void goToForgotPassword() {
    NavigatorHelper.pushNamed('/auth/forgot_password');
  }

  void gotoRegister() {
    state = state.copyWith(errors: {});
    NavigatorHelper.pushNamed('/auth/register');
  }

  void closeMenu() {
    state = state.copyWith(openMenu: !state.openMenu);
  }
}

bool isEmail(String input) {
  final emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(input);
}

final authProvider = StateNotifierProvider<_AuthNotifier, _AuthState>(
  (ref) => _AuthNotifier(
    ref: ref,
  ),
);
