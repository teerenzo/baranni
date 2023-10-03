import 'package:barrani/constants.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/models/invitation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> webAddAppointment(Map<String, dynamic> data) async {
  final response = await FirebaseFirestore.instance
      .collection(fireBaseCollections.appointments)
      .add(data);
  return response.id;
}

Future<void> webSendInvitation(
  String receiverId,
  String appointmentId,
  String status,
  Map<String, dynamic> appointmentInfo,
) async {
  if (userData!.userId != receiverId) {
    await FirebaseFirestore.instance
        .collection(fireBaseCollections.invitations)
        .add({
      'sender_id': userData!.userId,
      'receiver_id': receiverId,
      'appointment_id': appointmentId,
      'status': status,
      'appointment_info': appointmentInfo,
    });
  }
}

Future<void> webSendNotification(
    String title, String body, String userId) async {
  await FirebaseFirestore.instance
      .collection(fireBaseCollections.notifications)
      .add({
    'title': title,
    'body': body,
    'userId': userId,
    'createdAt': DateTime.now(),
    'isRead': false,
  });
}

Future<void> webUpdateInvitation(Invitation invitation, String status) async {
  try {
    await FirebaseFirestore.instance
        .collection(fireBaseCollections.invitations)
        .doc(invitation.id)
        .update({
      'status': status,
    });

    var appointment = await FirebaseFirestore.instance
        .collection(fireBaseCollections.appointments)
        .doc(invitation.appointmentId)
        .get();

    var attendees = appointment['attendees'];
    //update attend where id = invitation.senderId
    attendees.forEach((element) {
      if (element['userId'] == invitation.receiverId) {
        element['status'] = status;
      }
    });

    // update appointment
    await FirebaseFirestore.instance
        .collection(fireBaseCollections.appointments)
        .doc(invitation.appointmentId)
        .update({
      'attendees': attendees,
    });
  } catch (err) {}
}

Future<void> webDeleteInvitation(String id) async {
  try {
    FirebaseFirestore.instance
        .collection(fireBaseCollections.invitations)
        .doc(id)
        .delete();
  } catch (err) {}
}
