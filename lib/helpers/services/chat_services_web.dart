import 'package:barrani/global_variables.dart';
import 'package:barrani/models/ChatAppointment.dart';
import 'package:barrani/models/ChatInvitation.dart';
import 'package:barrani/models/GroupChat.dart';
import 'package:barrani/models/IndividualChat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatWebService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  static Future<GroupChat> fetchLastMessage(String roomId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('chatMessages')
          .where('appointmentId', isEqualTo: roomId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        GroupChat groupChat = GroupChat(
            querySnapshot.docs.first.id,
            querySnapshot.docs.first['appointmentId'],
            querySnapshot.docs.first['text'],
            querySnapshot.docs.first['timestamp'],
            querySnapshot.docs.first['senderId'],
            querySnapshot.docs.first['senderId'],
            querySnapshot.docs.first['type'] ?? 'text');

        return groupChat;
      } else {
        throw Exception('No message found');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<List<ChatInvitation>> fetchGroupData() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('invitations')
          .where("status", isEqualTo: "accepted")
          .where('receiver_id', isEqualTo: userData!.userId)
          .get();

      final secondQuerySnapshot = await FirebaseFirestore.instance
          .collection('invitations')
          .where('sender_id', isEqualTo: userData!.userId)
          .get();

      final documents = [...querySnapshot.docs, ...secondQuerySnapshot.docs];

      List<ChatInvitation> invitations = [];
      Set<String> uniqueAppointmentIds =
          <String>{}; // to store unique appointment IDs

      for (var element in documents) {
        String appointmentId = element['appointment_id'];

        // Check if appointment ID is already added to avoid duplication
        if (!uniqueAppointmentIds.contains(appointmentId)) {
          uniqueAppointmentIds.add(appointmentId);

          Timestamp startDateTimeStamp =
              element['appointment_info']['startTime'];
          Timestamp endDateTimeStamp = element['appointment_info']['endTime'];

          DateTime startDate = startDateTimeStamp.toDate();
          DateTime endDate = endDateTimeStamp.toDate();

          ChatInvitation invitation = ChatInvitation(
            senderId: element['sender_id'],
            receiverId: element['receiver_id'],
            appointmentId: appointmentId,
            status: element['status'],
            appointmentInfo: AppointmentInfo(
              endTime: endDate,
              startTime: startDate,
              location: element['appointment_info']['location'],
              subject: element['appointment_info']['subject'],
            ),
          );

          invitations.add(invitation);
        }
      }

      return invitations;
    } catch (e) {
      return [];
    }
  }

  Future<List<GroupChat>> fetchGroupChat(String roomId) async {
    try {
      final querySnapshot = await _firestore
          .collection('chatMessages')
          .where('appointmentId', isEqualTo: roomId)
          .orderBy('timestamp', descending: false)
          .get();

      List<GroupChat> groupChats = [];

      for (var element in querySnapshot.docs) {
        Timestamp sendAt = element['timestamp'];
        DateTime sendAtTime = sendAt.toDate();

        GroupChat groupChat = GroupChat(
            element['senderId'],
            element['text'],
            sendAtTime,
            element['senderId'],
            element['appointmentId'],
            element['senderId'] == userData!.userId ? true : false,
            element['type'] ?? 'text');
        groupChats.add(groupChat);
      }

      return groupChats;
    } catch (e) {
      return [];
    }
  }

  Future<IndividualChat> fetchIndividualChat(String receiverId) async {
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

      if (querySnapshot.isNotEmpty) {
        var doc = querySnapshot.first;
        List<Messages> messages = [];
        // fetch subcollection
        var subCollection = await _firestore
            .collection('individualChats')
            .doc(doc.id)
            .collection('messages')
            .orderBy('timestamp', descending: false)
            .get();

        for (var element in subCollection.docs) {
          Timestamp sendAt = element['timestamp'];
          DateTime sendAtTime = sendAt.toDate();

          Messages message = Messages(
            message: element['message'],
            senderId: element['senderId'],
            timestamp: sendAtTime,
            username: element['username'],
          );
          messages.add(message);
        }

        Timestamp created = doc['createdAt'];
        DateTime sendAtTime = created.toDate();

        return IndividualChat(
          messages: "",
          createdAt: sendAtTime,
          createdBy: doc['createdBy'],
          receiverId: doc['receiverId'],
        );
      } else {
        throw Exception('No message found');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<ChatAppointment> fetchAppointmentData(
      String currentSelectedGroup) async {
    try {
      var appointment = await _firestore
          .collection('appointments')
          .doc(currentSelectedGroup)
          .get();

      List<Attendees> attendees = [];
      for (var item in appointment['attendees']) {
        var user =
            await _firestore.collection('users').doc(item['userId']).get();
        attendees.add(Attendees(
            userId: item['userId'], email: user['email'], role: user['role']));
      }

      Timestamp endTime = appointment['endTime'];
      DateTime endDate = endTime.toDate();

      Timestamp startTime = appointment['startTime'];
      DateTime startDate = startTime.toDate();

      return ChatAppointment(
        attendees: attendees,
        endTime: endDate,
        location: appointment['location'],
        startTime: startDate,
        subject: appointment['subject'],
      );
    } catch (e) {
      throw Exception(e);
    }
  }

  //fetch invitation data and then fetch appointment data

  Future<List<ChatAppointment>> fetchSameGroupAttendees() async {
    try {
      final querySnapshot = await _firestore
          .collection('invitations')
          .where("status", isEqualTo: "accepted")
          .where('receiver_id', isEqualTo: userData!.userId)
          .get();

      final secondQuerySnapshot = await _firestore
          .collection('invitations')
          .where('sender_id', isEqualTo: userData!.userId)
          .get();

      final documents = [...querySnapshot.docs, ...secondQuerySnapshot.docs];

      List<ChatAppointment> appointments = [];

      List<Attendees> attendees = [];

      for (var element in documents) {
        var appointment = await _firestore
            .collection('appointments')
            .doc(element['appointment_id'])
            .get();
        Timestamp startDateTimeStamp = element['appointment_info']['startTime'];

        Timestamp endDateTimeStamp = element['appointment_info']['endTime'];

        DateTime startDate = startDateTimeStamp.toDate();

        DateTime endDate = endDateTimeStamp.toDate();

        for (var item in appointment['attendees']) {
          if (userData!.userId == item['userId']) continue;
          var user =
              await _firestore.collection('users').doc(item['userId']).get();

          var isUserExist = attendees
              .where((element) => element.userId == item['userId'])
              .toList();
          if (isUserExist.isNotEmpty) continue;

          attendees.add(Attendees(
            userId: item['userId'],
            email: user['email'],
            role: user['role'],
            names: item['names'] ?? '',
            status: item['status'] ?? '',
            isCreator: item['isCreator'] ?? false,
          ));
        }

        appointments.add(ChatAppointment(
            endTime: endDate,
            startTime: startDate,
            location: element['appointment_info']['location'],
            subject: element['appointment_info']['subject'],
            attendees: attendees));
      }

      return appointments;
    } catch (e) {
      return [];
    }
  }

  Future<void> sendMessage(
    String message,
    String currentSelectedGroup,
    String type,
  ) async {
    if (message.isEmpty) return;
    //send message to firebase
    _firestore.collection("chatMessages").add({
      "appointmentId": currentSelectedGroup,
      "text": message,
      "timestamp": DateTime.now(),
      "senderId": userData!.userId,
      "type": type,
    });
  }

  Future<void> sendIndividualMsg(
      String receiverId, String message, String type) async {
    if (message.isEmpty) return;
    _firestore.collection("messages").add({
      "chatId": receiverId + "_" + userData!.userId,
      "message": message,
      "timestamp": DateTime.now(),
      "senderId": userData!.userId,
      "names": userData!.names,
      "receiverId": receiverId,
      "type": type
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
