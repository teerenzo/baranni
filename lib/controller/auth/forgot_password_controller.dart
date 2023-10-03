import 'package:barrani/controller/my_controller.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/helpers/services/auth_services.dart';
import 'package:barrani/helpers/services/web_auth_services.dart';
import 'package:barrani/helpers/widgets/my_form_validator.dart';
import 'package:barrani/helpers/widgets/my_validators.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ForgotPasswordController extends MyController {
  MyFormValidator basicValidator = MyFormValidator();
  bool showPassword = false, loading = false;

  @override
  void onInit() {
    super.onInit();
    basicValidator.addField(
      'email',
      required: true,
      label: "Email",
      validators: [MyEmailValidator()],
      controller: TextEditingController(),
    );
  }

  Future<void> onForgotPassword() async {
    if (basicValidator.validateForm()) {
      loading = true;
      update();
      var errors = kIsWeb
          ? await WebAuthService.forgotPassword(basicValidator.getData())
          : await AuthService.forgotPassword(basicValidator.getData());
      if (errors != null) {
        basicValidator.validateForm();
        basicValidator.addErrors(errors);
      } else {
        basicValidator.clearErrors();
        gotoLogIn();
      }
      loading = false;
      update();
    }
  }

  void gotoLogIn() {
    NavigatorHelper.pushNamed('/auth/login');
  }
}
