import 'dart:io';

import 'package:barrani/constants.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/models/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firedart/auth/user_gateway.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<User> signIn(String email, String password) async {
  return await _auth.signIn(email, password);
}

Future<void> getUserData() async {
  if (_auth.isSignedIn) {
    await Firestore.instance
        .collection(fireBaseCollections.users)
        .where('userId', isEqualTo: _auth.userId)
        .get()
        .then((value) {
      if (value.isNotEmpty) {
        userData = UserModal.fromJSON(value.first.map);
      }
    });
  } else {
    userData = null;
  }
}

bool isUserExist(String userId) {
  return currentUsers.where((element) => element.userId == userId).isNotEmpty;
}

Future<bool> isValidInvitationCode(String code) async {
  var snapshot = await Firestore.instance
      .collection(fireBaseCollections.userInvitations)
      .where('invitation', isEqualTo: code)
      .get();

  if (snapshot.isNotEmpty) {
    var data = snapshot.first.map;

    if (data['userType'] == null || data['isUsed'] == null) {
      return false;
    }

    if (data['isUsed'] == false) {
      return true;
    }
    return false;
  }
  return false;
}

Future<void> signUp(
    String email, String password, String invitationCode) async {
  var isValidCode = await isValidInvitationCode(invitationCode);
  if (isValidCode) {
    var user = await _auth.signUp(email, password);
    if (!isUserExist(user.id)) {
      // update invitationcolectio where code
      var invitation = await Firestore.instance
          .collection(fireBaseCollections.userInvitations)
          .where('invitation', isEqualTo: invitationCode)
          .get();

      await Firestore.instance
          .document(
              '${fireBaseCollections.userInvitations}/${invitation.first.id}')
          .update({'isUsed': true});

      // add use to user collection
      await Firestore.instance
          .document('${fireBaseCollections.users}/${user.id}')
          .create({
        'email': email,
        'names': invitation.first['names'],
        'userId': user.id,
        'role': invitation.first['userType']
      });
    } else {
      throw Error();
    }
  } else {
    throw Error();
  }
}

Future<bool> isEmailExist(String email) async {
  var snapshot = await Firestore.instance
      .collection(fireBaseCollections.users)
      .where('email', isEqualTo: email)
      .get();
  if (snapshot.isNotEmpty) {
    return true;
  }
  return false;
}

Future<void> resetPassword(String email) async {
  // check if email exist
  var isExist = await isEmailExist(email);
  if (!isExist) {
    throw Error();
  }
  await _auth.resetPassword(email);
  Get.snackbar(
    'Success',
    'Password reset email sent',
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: Colors.green,
    colorText: Colors.white,
  );
}

Future<void> updateUser(Map<String, dynamic> data) async {
  await Firestore.instance.document('users/${userData?.userId}').update(data);
}

Future<String> uploadProfile(PlatformFile imageFile) async {
  final ref = FirebaseStorage.instance.ref().child(
      'profiles/${DateTime.now().millisecondsSinceEpoch}${imageFile.name}');
  final UploadTask uploadTask = ref.putFile(File(imageFile.path!));
  final TaskSnapshot storageSnapshot = await uploadTask.whenComplete(() {});

  final imageUrl = await storageSnapshot.ref.getDownloadURL();
  return imageUrl;
}

Future<void> deleteProfile(String? imgUrl) async {
  if (imgUrl != null) {
    await FirebaseStorage.instance.refFromURL(imgUrl).delete();
  }
}

Future<Map<String, dynamic>> getUser() async {
  if (_auth.isSignedIn) {
    List<Document> snapshot = await Firestore.instance
        .collection(fireBaseCollections.users)
        .where(
          'userId',
          isEqualTo: _auth.userId,
        )
        .get();
    if (snapshot.isNotEmpty) {
      return snapshot.first.map;
    }
  }
  return {};
}

void signOut() {
  try {
    _auth.signOut();
    userData = null;
  } catch (err) {}
}

bool isLoggedUser() {
  return _auth.isSignedIn;
}
