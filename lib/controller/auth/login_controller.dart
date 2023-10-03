import 'package:barrani/controller/my_controller.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/helpers/services/auth_services.dart';
import 'package:barrani/helpers/services/web_auth_services.dart';
import 'package:barrani/helpers/widgets/my_form_validator.dart';
import 'package:barrani/helpers/widgets/my_validators.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends MyController {
  MyFormValidator basicValidator = MyFormValidator();

  bool showPassword = false, loading = false, isChecked = false;

  final String _dummyEmail = "hello@gmail.com";
  final String _dummyPassword = "Hello@123";

  @override
  void onInit() {
    super.onInit();
    basicValidator.addField('email',
        required: true,
        label: "Email",
        validators: [MyEmailValidator()],
        controller: TextEditingController(text: _dummyEmail));

    basicValidator.addField('password',
        required: true,
        label: "Password",
        validators: [MyLengthValidator(min: 6, max: 10)],
        controller: TextEditingController(text: _dummyPassword));
  }

  void onChangeShowPassword() {
    showPassword = !showPassword;
    update();
  }

  void onChangeCheckBox(bool? value) {
    isChecked = value ?? isChecked;
    update();
  }

  Future<void> onLogin() async {
    if (basicValidator.validateForm()) {
      loading = true;
      update();
      var errors = kIsWeb
          ? await WebAuthService.loginUser(basicValidator.getData())
          : await AuthService.loginUser(basicValidator.getData());
      if (errors != null) {
        basicValidator.addErrors({});
        basicValidator.validateForm();
        basicValidator.clearErrors();
      } else {
        String nextUrl =
            Uri.parse(ModalRoute.of(Get.context!)?.settings.name ?? "")
                    .queryParameters['next'] ??
                "/dashboard";
        NavigatorHelper.pushNamed(nextUrl);
      }
      loading = false;
      update();
    }
  }

  void goToForgotPassword() {
    NavigatorHelper.pushNamed('/auth/forgot_password');
  }

  void gotoRegister() {
    Get.toNamed('/auth/register');
    // Get.offAndToNamed('/auth/register');
  }
}
