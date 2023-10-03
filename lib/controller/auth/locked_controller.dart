import 'package:barrani/controller/my_controller.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/helpers/widgets/my_form_validator.dart';
import 'package:barrani/helpers/widgets/my_validators.dart';
import 'package:flutter/material.dart';

class LockedController extends MyController {
  MyFormValidator basicValidator = MyFormValidator();

  bool showPassword = false, loading = false;

  @override
  void onInit() {
    super.onInit();

    basicValidator.addField(
      'password',
      required: true,
      label: 'Password',
      validators: [MyLengthValidator(min: 6, max: 10)],
      controller: TextEditingController(),
    );
  }

  void onShowPassword() {
    showPassword = !showPassword;
    update();
  }

  // Services
  Future<void> onLock() async {
    if (basicValidator.validateForm()) {
      loading = true;
      update();
      await Future.delayed(Duration(seconds: 1));
      NavigatorHelper.pushNamed('/dashboard');

      loading = false;
      update();
    }
  }
}
