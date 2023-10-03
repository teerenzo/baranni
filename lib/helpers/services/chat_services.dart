import 'package:barrani/constants.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/models/ChatAppointment.dart';
import 'package:barrani/models/ChatInvitation.dart';
import 'package:barrani/models/GroupChat.dart';
import 'package:barrani/models/IndividualChat.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Firestore _firestore = Firestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

Future<GroupChat> fetchLastMessage(String roomId) async {
  try {
    final querySnapshot = await Firestore.instance
        .collection('chatMessages')
        .where('appointmentId', isEqualTo: roomId)
        .orderBy('timestamp', descending: false)
        .limit(1)
        .get();

    if (querySnapshot.isNotEmpty) {
      GroupChat groupChat = GroupChat(
          querySnapshot.first.id,
          querySnapshot.first['text'],
          querySnapshot.first['timestamp'],
          querySnapshot.first['senderId'],
          roomId,
          querySnapshot.first['senderId'].toString().contains(userData!.userId),
          querySnapshot.first['type']);

      return groupChat;
    } else {
      throw Exception('No message found');
    }
  } catch (e) {
    throw Exception(e);
  }
}

final streamGroupChat = StreamProvider<List<GroupChat>>((ref) {
  try {
    return _firestore.collection('chatMessages').stream.map(
      (querySnapshot) {
        List<GroupChat> groupChats = [];

        for (var element in querySnapshot) {
          GroupChat groupChat = GroupChat(
              element['senderId'],
              element['text'],
              element['timestamp'],
              element['senderId'],
              element['appointmentId'],
              element['senderId'] == userData!.userId ? true : false,
              element['type']);
          groupChats.add(groupChat);
        }

        return groupChats;
      },
    );
  } catch (e) {
    return Stream.value([]);
  }
});

Future<ChatAppointment> fetchAppointmentData(
    String currentSelectedGroup) async {
  try {
    var appointment = await _firestore
        .collection('appointments')
        .document(currentSelectedGroup)
        .get();

    List<Attendees> attendees = [];
    for (var item in appointment['attendees']) {
      var user =
          await _firestore.collection('users').document(item['userId']).get();

      attendees.add(Attendees(
          userId: user.id,
          names: user['names'],
          email: user['email'],
          role: user['role'],
          profile_url: user['profile_url']));
    }

    return ChatAppointment(
      attendees: attendees,
      endTime: appointment['endTime'],
      location: appointment['location'],
      startTime: appointment['startTime'],
      subject: appointment['subject'],
    );
  } catch (e) {
    throw Exception(e);
  }
}

Stream<List<Messages>> fetchIndividualChat(String receiverId) {
  try {
    final query = [
      receiverId + "_" + userData!.userId,
      userData!.userId + "_" + receiverId
    ];
    return _firestore
        .collection('messages')
        .where('chatId', whereIn: query) // equal or not
        .get()
        .asStream()
        .map((querySnapshot) {
      List<Messages> messages = [];

      for (var element in querySnapshot) {
        Messages message = Messages(
          message: element['message'],
          senderId: element['senderId'],
          timestamp: element['timestamp'],
          username: element['username'],
        );
        messages.add(message);
      }
      return messages;
    });
  } catch (e) {
    throw Exception(e);
  }
}

final streamIndividualChat = StreamProvider<List<Messages>>((ref) {
  try {
    return _firestore.collection('messages').stream.map(
      (querySnapshot) {
        List<Messages> messages = [];

        for (var element in querySnapshot) {
          Messages individualChat = Messages(
            message: element['message'],
            senderId: element['senderId'],
            timestamp: element['timestamp'],
            username: element['names'],
            receiverId: element['receiverId'],
            chatId: element['chatId'],
            type: element['type'],
          );
          messages.add(individualChat);
        }

        return messages
            .where((element) =>
                element.senderId == userData!.userId ||
                element.receiverId == userData!.userId)
            .toList();
      },
    );
  } catch (e) {
    return Stream.value([]);
  }
});

final fetchGroupData = StreamProvider<List<ChatInvitation>>((ref) {
  try {
    return Firestore.instance
        .collection(fireBaseCollections.invitations)
        .get()
        .asStream()
        .map((event) {
      List<ChatInvitation> invitations = [];

      for (var element in event) {
        String appointmentId = element['appointment_id'];
        ChatInvitation invitation = ChatInvitation(
          senderId: element['sender_id'],
          receiverId: element['receiver_id'],
          appointmentId: appointmentId,
          status: element['status'],
          appointmentInfo: AppointmentInfo(
            endTime: element['appointment_info']['endTime'],
            startTime: element['appointment_info']['startTime'],
            location: element['appointment_info']['location'],
            subject: element['appointment_info']['subject'],
          ),
        );
        if (invitations
                .where((element) =>
                    element.appointmentId == invitation.appointmentId)
                .length ==
            0) {
          invitations.add(invitation);
        }
      }

      return invitations
          .where((element) => (element.receiverId == userData!.userId ||
              element.senderId == userData!.userId))
          .toList();
    });
  } catch (e) {
    return Stream.value([]);
  }
});

final fetchSameGroupAttendees = StreamProvider<List<Attendees>>((ref) async* {
  try {
    final query = Firestore.instance.collection('invitations');

    final bySender =
        await query.where("sender_id", isEqualTo: userData!.userId).get();
    final byReceiver =
        await query.where("receiver_id", isEqualTo: userData!.userId).get();

    List<Document> documents = [...byReceiver, ...bySender];

    List<Attendees> attendees = [];
    List<ChatAppointment> appointments = [];

    for (var element in documents) {
      final appointmentId = element['appointment_id'];

      final appointment = await Firestore.instance
          .collection('appointments')
          .document(appointmentId)
          .get();

      for (var item in appointment['attendees']) {
        if (userData!.userId == item['userId']) continue;

        final user = await Firestore.instance
            .collection('users')
            .document(item['userId'])
            .get();

        if (attendees.every((attendee) => attendee.userId != item['userId'])) {
          attendees.add(Attendees(
              userId: item['userId'],
              email: user['email'],
              names: item['names'],
              role: user['role'],
              profile_url: user['profile_url']));
        }
      }

      appointments.add(ChatAppointment(
        endTime: appointment['endTime'],
        startTime: appointment['startTime'],
        location: element['appointment_info']['location'],
        subject: element['appointment_info']['subject'],
        attendees: attendees,
      ));
    }
    yield attendees;
  } catch (e) {
    yield [];
  }
});

Future<void> sendGroupMessage(
    String message, String currentSelectedGroup, String type) async {
  if (message.isEmpty) return;
  //send message to firebase
  await Firestore.instance.collection("chatMessages").add({
    "appointmentId": currentSelectedGroup,
    "text": message,
    "timestamp": DateTime.now(),
    "senderId": userData!.userId,
    "type": type
  });
}

Future<void> sendIndividualMsg(
    String receiverId, String message, String type) async {
  if (message.isEmpty) return;

  // final docId = await isChatExist(receiverId);

  // if (docId.isEmpty) {
  // final createdDoc =
  //     await Firestore.instance.collection("individualChats").add({
  //   "receiverId": receiverId,
  //   "createdBy": userData!.userId,
  //   "createdAt": DateTime.now(),
  // });
  await Firestore.instance.collection("messages").add({
    "chatId": receiverId + "_" + userData!.userId,
    "message": message,
    "timestamp": DateTime.now(),
    "senderId": userData!.userId,
    "names": userData!.names,
    "receiverId": receiverId,
    "type": type
  });
  // }
  // else {
  //   await Firestore.instance.collection("messages").add({
  //     "message": messageController.text,
  //     "timestamp": DateTime.now(),
  //     "senderId": userData!.userId,
  //     "username": userData!.names,
  //     "receiverId": receiverId
  //   });
  // }
}

Future<String> isChatExist(String receiverId) async {
  try {
    final fetchSender = await Firestore.instance
        .collection('individualChats')
        .where('receiverId', isEqualTo: userData!.userId)
        .where('createdBy', isEqualTo: receiverId)
        .get();

    var fetchReceiver = await Firestore.instance
        .collection('individualChats')
        .where('receiverId', isEqualTo: receiverId)
        .where('createdBy', isEqualTo: userData!.userId)
        .get();
    final querySnapshot = [...fetchSender, ...fetchReceiver];
    return querySnapshot.first.id;
  } catch (e) {
    return "";
  }
}
