import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barrani/helpers/services/chat_services.dart';
import 'package:barrani/models/ChatAppointment.dart';
import 'package:barrani/models/GroupChat.dart';
import 'package:barrani/models/chat.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../helpers/firebase/firebase_web_helper.dart';
import '../../helpers/services/chat_services_web.dart';

final chatControllerProvider =
    ChangeNotifierProvider((ref) => ChatController());

class ChatController extends ChangeNotifier {
  List<Chat> chat = [];
  List<Attendees> attendees = [];
  bool isLoading = false;
  String currentSelectedGroup = "All";
  Map currentSelectedUser = {};
  TextEditingController messageController = TextEditingController();
  final ScrollController GroupScrollController = ScrollController();
  final ScrollController scrollController = ScrollController();

  final searchProvider = StateProvider<String>((ref) => '');

  List<GroupChat> groupChat = [];

  File? imageFile;

  void _scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    // GroupScrollController.animateTo(
    //   GroupScrollController.position.maxScrollExtent,
    //   duration: Duration(milliseconds: 300),
    //   curve: Curves.easeOut,
    // );
  }

  Future<String?> uploadImageToFirebase(File imageFile) async {
    final String bucket = 'webkit-5cc0f.appspot.com';
    final String path = 'chat';
    final String fileName =
        'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final String uploadUrl =
        'https://firebasestorage.googleapis.com/v0/b/$bucket/o?name=$path%2F$fileName';

    try {
      final response = await http.post(
        Uri.parse(uploadUrl),
        headers: {
          'Content-Type': 'application/octet-stream',
        },
        body: imageFile.readAsBytesSync(),
      );

      if (response.statusCode == 200) {
        String downloadUrl =
            "https://firebasestorage.googleapis.com/v0/b/webkit-5cc0f.appspot.com/o/${path}%2F${fileName}?alt=media&token=${jsonDecode(response.body)['downloadTokens']}";

        return downloadUrl;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  void setAttendees(List<Attendees> attendes) {
    attendees = attendes;
    notifyListeners();
  }

  Future<void> sendMessage() async {
    isLoading = true;
    if (messageController.text.isEmpty) return;
    if (kIsWeb) {
      await ChatWebService()
          .sendMessage(messageController.text, currentSelectedGroup, "text");
      // _scrollToBottom();
    } else {
      await sendGroupMessage(
          messageController.text, currentSelectedGroup, "text");
      // _scrollToBottom();
    }
    isLoading = false;
    messageController.clear();
    notifyListeners();
  }

  Future<void> sendIndividualMessage(String receiverId) async {
    if (messageController.text.isEmpty) return;
    isLoading = true;
    kIsWeb
        ? await ChatWebService()
            .sendIndividualMsg(receiverId, messageController.text, "text")
        : await sendIndividualMsg(receiverId, messageController.text, "text");
    // _scrollToBottom();
    isLoading = false;
    messageController.clear();
    notifyListeners();
  }

  void setCurrentSelectGroup(String invitation) {
    currentSelectedGroup = invitation;
    currentSelectedUser = {};
    notifyListeners();
  }

  void setCurrentSelectedUser(Map user) {
    currentSelectedUser = user;
    notifyListeners();
  }

  void setCurrentSelectedUser1(Map user) {
    currentSelectedUser = user;
    notifyListeners();
  }

  void setGroupChat(List<GroupChat> groupChat) {
    this.groupChat = groupChat;
    notifyListeners();
  }

  Future getImage(String receiverId) async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) async {
      if (xFile != null) {
        imageFile = File(xFile.path);
        if (currentSelectedGroup == "All" || currentSelectedGroup == "") {
          String? imageUrl = kIsWeb
              ? await FirebaseWebHelper.uploadWebImageToFirebase(
                  XFile(imageFile!.path),
                )
              : await uploadImageToFirebase(imageFile!);

          kIsWeb
              ? await ChatWebService()
                  .sendIndividualMsg(receiverId, imageUrl!, "image")
              : await sendIndividualMsg(receiverId, imageUrl!, "image");
        } else {
          String? imageUrl = kIsWeb
              ? await FirebaseWebHelper.uploadWebImageToFirebase(
                  XFile(imageFile!.path),
                )
              : await uploadImageToFirebase(imageFile!);
          kIsWeb
              ? await ChatWebService()
                  .sendMessage(imageUrl!, currentSelectedGroup, "image")
              : await sendGroupMessage(
                  imageUrl!, currentSelectedGroup, "image");
        }
      }
    });
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> initializeChat() async {
    chat = await Chat.dummyList.then((value) => value.sublist(0, 10));
    notifyListeners();
  }
}
