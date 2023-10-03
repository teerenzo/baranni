import 'package:barrani/controller/my_controller.dart';
import 'package:barrani/helpers/widgets/my_form_validator.dart';

class EditProfileController extends MyController {
  MyFormValidator validation = MyFormValidator();
  bool showPassword = false;

  void onChangeShowPassword() {
    showPassword = !showPassword;
    update();
  }
}
