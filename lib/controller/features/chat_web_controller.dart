import 'package:barrani/controller/my_controller.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/models/GroupChat.dart';
import 'package:barrani/models/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatController extends MyController {
  List<Chat> chat = [];

  bool isLoading = false;

  String currentSelectedGroup = "All";
  Map currentSelectedUser = {};

  TextEditingController messageController = TextEditingController();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get loggedInUser

  FirebaseAuth auth = FirebaseAuth.instance;

  List<GroupChat> groupChat = [];

  void sendMessage() async {
    isLoading = true;
    if (messageController.text.isEmpty) return;
    //send message to firebase
    await firestore.collection("chatMessages").add({
      "appointmentId": currentSelectedGroup,
      "text": messageController.text,
      "timestamp": DateTime.now(),
      "senderId": userData!.userId,
    });
    isLoading = false;
    messageController.clear();
    update();
  }

  Future<void> sendIndividualMessage(String receiverId) async {
    if (messageController.text.isEmpty) return;
    isLoading = true;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    final docId = await isChatExist(receiverId);

    if (docId.isEmpty) {
      final createdDoc = await firestore.collection("individualChats").add({
        "receiverId": receiverId,
        "createdBy": userData!.userId,
        "createdAt": DateTime.now(),
      });
      await firestore
          .collection("individualChats")
          .doc(createdDoc.id)
          .collection("messages")
          .add({
        "message": messageController.text,
        "timestamp": DateTime.now(),
        "senderId": userData!.userId,
        "username": userData!.names,
      });
    } else {
      await firestore
          .collection("individualChats")
          .doc(docId)
          .collection("messages")
          .add({
        "message": messageController.text,
        "timestamp": DateTime.now(),
        "senderId": userData!.userId,
        "username": userData!.names,
      });
    }
    isLoading = false;
    messageController.clear();
    update();
  }

  void setCurrentSelectGroup(String invitation) {
    currentSelectedGroup = invitation;
    currentSelectedUser = {};
    update();
  }

  void setCurrentSelectedUser(Map user) {
    currentSelectedUser = user;
    update();
  }

  setGroupChat(List<GroupChat> groupChat) {
    this.groupChat = groupChat;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    Chat.dummyList.then((value) {
      chat = value.sublist(0, 10);
      update();
    });
  }

  Future<String> isChatExist(String receiverId) async {
    try {
      final fetchSender = await _firestore
          .collection('individualChats')
          .where('receiverId', isEqualTo: userData!.userId)
          .where('createdBy', isEqualTo: receiverId)
          .get();

      var fetchReceiver = await _firestore
          .collection('individualChats')
          .where('receiverId', isEqualTo: receiverId)
          .where('createdBy', isEqualTo: userData!.userId)
          .get();
      final querySnapshot = [...fetchSender.docs, ...fetchReceiver.docs];
      return querySnapshot.first.id;
    } catch (e) {
      return "";
    }
  }
}
