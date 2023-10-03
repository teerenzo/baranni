import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../storage/local_storage.dart';

class WebAuthService {
  static bool isLoggedIn = false;

  static Future<UserModal?> loginUser(Map<String, dynamic> data) async {
    try {
      await FirebaseWebHelper.signIn(
          email: data['email'], password: data['password']);

      Map<String, dynamic>? userInfo = await FirebaseWebHelper.getUserById(
          FirebaseAuth.instance.currentUser!.uid);
      if (userInfo != null) {
        userData = UserModal.fromJSON(userInfo);
        await LocalStorage.storeUserdata(userData!);
      }
      await LocalStorage.setLoggedInUser(true);
      isLoggedIn = true;
      return userData;
    } catch (e) {
      return null;
    }
  }

  static Future<void> logoutUser() async {
    await FirebaseWebHelper.logout();
  }

  static Future<Map<String, String>?> registerUser(
      Map<String, dynamic> data) async {
    try {
      await FirebaseWebHelper.signUp(
          email: data['email'],
          password: data['password'],
          invitationCode: data['invitationCode']);
      return null;
    } catch (e) {
      return {'error': 'Invalid invitation code or user already registered'};
    }
  }

  static Future<Map<String, String>?> forgotPassword(
      Map<String, dynamic> data) async {
    try {
      await FirebaseWebHelper.forgotPassword(email: data['email']);
      return null;
    } catch (e) {
      return {'errorForgotPassword': 'email not exist in our database'};
    }
  }

  static bool isLoggedUser() {
    return FirebaseWebHelper.isLoggedUser();
  }
}
