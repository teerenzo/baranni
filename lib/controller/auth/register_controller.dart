import 'package:barrani/controller/my_controller.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/helpers/services/auth_services.dart';
import 'package:barrani/helpers/services/web_auth_services.dart';
import 'package:barrani/helpers/widgets/my_form_validator.dart';
import 'package:barrani/helpers/widgets/my_validators.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RegisterController extends MyController {
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
    basicValidator.addField(
      'names',
      required: true,
      label: 'Names',
      controller: TextEditingController(),
    );
    // basicValidator.addField(
    //   'last_name',
    //   required: true,
    //   label: 'Last Name',
    //   controller: TextEditingController(),
    // );
    basicValidator.addField(
      'password',
      required: true,
      validators: [MyLengthValidator(min: 6, max: 10)],
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'invitationCode',
      required: true,
      validators: [MyLengthValidator(min: 6, max: 10)],
      controller: TextEditingController(),
    );
  }

  Future<void> onLogin() async {
    if (basicValidator.validateForm()) {
      loading = true;
      update();
      var errors = await AuthService.loginUser(basicValidator.getData());
      if (errors != null) {
        basicValidator.addErrors(errors);
        basicValidator.validateForm();
        basicValidator.clearErrors();
      }
      NavigatorHelper.pushNamed('/starter');

      loading = false;
      update();
    }
  }

  Future<void> onRegister() async {
    if (basicValidator.validateForm()) {
      loading = true;
      update();
      var errors = kIsWeb
          ? await WebAuthService.registerUser(basicValidator.getData())
          : await AuthService.registerUser(basicValidator.getData());
      if (errors != null) {
        basicValidator.addErrors(errors);
        basicValidator.validateForm();
      } else {
        basicValidator.clearErrors();
        basicValidator.resetForm();
        gotoLogin();
      }
      loading = false;
      update();
    }
  }

  void onChangeShowPassword() {
    showPassword = !showPassword;
    update();
  }

  void gotoLogin() {
    NavigatorHelper.pushNamed('/auth/login');
  }
}
