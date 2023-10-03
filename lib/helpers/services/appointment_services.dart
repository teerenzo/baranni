import 'package:barrani/constants.dart';
import 'package:barrani/global_variables.dart';
import 'package:firedart/firedart.dart';

Future<String> addAppointment(Map<String, dynamic> data) async {
  final response = await Firestore.instance
      .collection(fireBaseCollections.appointments)
      .add(data);
  return response.id;
}

Future<void> sendInvitation(
  String receiverId,
  String appointmentId,
  String status,
  Map<String, dynamic> appointmentInfo,
) async {
  if (userData!.userId != receiverId) {
    await Firestore.instance.collection(fireBaseCollections.invitations).add({
      'sender_id': userData?.userId,
      'receiver_id': receiverId,
      'appointment_id': appointmentId,
      'status': status,
      'appointment_info': appointmentInfo,
    });
  }
}

Future<void> sendNotification(String title, String body, String userId) async {
  await Firestore.instance.collection(fireBaseCollections.notifications).add({
    'title': title,
    'body': body,
    'userId': userId,
    'createdAt': DateTime.now(),
    'isRead': false,
  });
}
