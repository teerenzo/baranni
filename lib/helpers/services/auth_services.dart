import 'package:barrani/helpers/firebase/auth.dart';

import '../storage/local_storage.dart';

class AuthService {
  static bool isLoggedIn = false;

  static Future<Map<String, String>?> loginUser(
      Map<String, dynamic> data) async {
    try {
      await signIn(data['email'], data['password']);
      getUserData();
      await LocalStorage.setLoggedInUser(true);
      isLoggedIn = true;
      return null;
    } catch (e) {
      return {'error': 'Invalid email or password'};
    }
  }

  static Future<Map<String, String>?> registerUser(
      Map<String, dynamic> data) async {
    try {
      await signUp(data['email'], data['password'], data['invitationCode']);
      return null;
    } catch (e) {
      return {'error': 'Invalid invitation code or user already registered'};
    }
  }

  static Future<Map<String, String>?> forgotPassword(
      Map<String, dynamic> data) async {
    try {
      await resetPassword(data['email']);
      return null;
    } catch (e) {
      return {'errorForgotPassword': 'email not exist in our database'};
    }
  }

  static bool isLogged() {
    return isLoggedUser();
  }
}
