import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:barrani/constants.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/storage/local_storage.dart';
import 'package:barrani/models/appointment.dart';
import 'package:barrani/models/invitation.dart';
import 'package:barrani/models/kanban.dart';
import 'package:barrani/models/notification.dart';
import 'package:barrani/models/user.dart';
import 'package:barrani/models/zone.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:http/http.dart' as http;

const bucketUrl = "https://storage.googleapis.com/storage/v1/b/thumbnail";

final allUsersStreamProvider = StreamProvider<List<UserModal>>((ref) {
  CollectionReference fireStoreQuery =
      Firestore.instance.collection(fireBaseCollections.users);
  return fireStoreQuery.stream.map((querySnapshot) {
    List<UserModal> users = [];
    for (var element in querySnapshot) {
      Map<String, dynamic> element_ = element.map;
      element_['id'] = element.id;
      users.add(UserModal.fromJSON(element_));
    }
    currentUsers = users;
    return users;
  });
});

final kanbanProjectsProvider = StreamProvider<List<KanbanProject>>((ref) {
  CollectionReference fireStoreQuery = Firestore.instance.collection(
      fireBaseCollections.project); // 'project' collection in Firestore
  return fireStoreQuery.stream.map((querySnapshot) {
    List<KanbanProject> projects = [];

    for (var element in querySnapshot) {
      Map<String, dynamic> element_ = element.map;
      element_['id'] = element
          .id; // Assuming you have an 'id' field in your KanbanProject model
      projects.add(KanbanProject.fromMap(
          element_)); // Assuming you have a fromMap constructor
    }
    return projects;
  });
});

final allAppointmentsStreamProvider = StreamProvider<List<Appointment>>((ref) {
  CollectionReference fireStoreQuery =
      Firestore.instance.collection(fireBaseCollections.appointments);
  return fireStoreQuery.stream.map((querySnapshot) {
    List<Appointment> appointments_ = [];

    for (var element in querySnapshot) {
      Map<String, dynamic> element_ = element.map;
      element_['id'] = element.id;
      appointments_.add(fromMap(element_));
    }
    appointments = appointments_;
    return appointments_;
  });
});

final allInvitationsStreamProvider = StreamProvider<List<Invitation>>((ref) {
  CollectionReference fireStoreQuery =
      Firestore.instance.collection(fireBaseCollections.invitations);

  return fireStoreQuery.stream.map((querySnapshot) {
    List<Invitation> invitations_ = [];

    for (var element in querySnapshot) {
      Map<String, dynamic> element_ = element.map;
      element_['id'] = element.id;
      invitations_.add(Invitation.fromJSON(element_));
    }
    invitations = invitations_;
    return invitations_;
  });
});

final allZonesStreamProvider = StreamProvider<List<PlaceZone>>((ref) {
  CollectionReference fireStoreQuery =
      Firestore.instance.collection(fireBaseCollections.zones);

  return fireStoreQuery.stream.map((querySnapshot) {
    List<PlaceZone> zones_ = [];

    for (var element in querySnapshot) {
      Map<String, dynamic> element_ = element.map;
      element_['id'] = element.id;
      zones_.add(PlaceZone.fromJson(element_));
    }
    zones = zones_;
    return zones_;
  });
});

//user notifications provider

final userNotificationsStreamProvider =
    StreamProvider<List<NotificationModal>>((ref) {
  CollectionReference fireStoreQuery =
      Firestore.instance.collection(fireBaseCollections.notifications);

  return fireStoreQuery.stream.map((querySnapshot) {
    List<NotificationModal> notifications_ = [];

    for (var element in querySnapshot) {
      Map<String, dynamic> element_ = element.map;
      element_['id'] = element.id;

      if (element_['userId'] == FirebaseAuth.instance.userId) {
        notifications_.add(NotificationModal.fromJson(element_));
      }
    }
    notifications = notifications_;
    return notifications_;
  });
});

Future<void> updateInvitation(Invitation invitation, String status) async {
  await Firestore.instance
      .document('${fireBaseCollections.invitations}/${invitation.id}')
      .update({
    'status': status,
  });

  var appointment = await Firestore.instance
      .collection(fireBaseCollections.appointments)
      .document(invitation.appointmentId)
      .get();

  var attendees = appointment['attendees'];
  //update attend where id = invitation.senderId
  attendees.forEach((element) {
    if (element['userId'] == invitation.receiverId) {
      element['status'] = status;
    }
  });

  // update appointment
  await Firestore.instance
      .collection(fireBaseCollections.appointments)
      .document(invitation.appointmentId)
      .update({
    'attendees': attendees,
  });
}

Future<void> onSavePressed(
    String? userId, String firstName, String lastName, String? imageUrl) async {
  await Firestore.instance
      .collection(fireBaseCollections.users)
      .document(userId!)
      .update({
    'names': firstName,
    if (imageUrl != null)
      'profile_url': imageUrl, // Only update imageUrl if it's not null
  }).then((value) async {
    userData = UserModal.fromJSON({
      'email': userData!.email,
      'names': firstName,
      'userId': userData!.userId,
      'photo_url': imageUrl,
      'role': userData!.role
    });
    await LocalStorage.storeUserdata(userData!);
  });
}

Future<void> onCreateKanbanProject({
  required String? userId,
  required String projectName,
  required String description,
  required DateTime startTimeDate,
  required DateTime endTimeDate,
  required List<String> inviteeIds,
  required String kanbanLevel,
  required String jobTypeName,
}) async {
  // Construct the document data
  Map<String, dynamic> data = {
    'userId': userId,
    'projectName': projectName,
    'description': description,
    'status': 'To Do',
    'startTime': startTimeDate,
    'endTime': endTimeDate,
    'assignedTo': inviteeIds,
    'kanbanLevel': kanbanLevel,
    'jobTypeName': jobTypeName
  };
  // Submit to Firestore
  await Firestore.instance.collection(fireBaseCollections.project).add(data);
}

Future<void> onUpdateKanbanProject({
  required String? projectId,
  required String status,
}) async {
  // Construct the document data
  // Submit to Firestore
  await Firestore.instance
      .collection(fireBaseCollections.project)
      .document(projectId!)
      .update({'status': status});
}

Future<String?> uploadThumbnail(File image) async {
  String token = await FirebaseAuth.instance.tokenProvider.idToken;
  final response = await http.put(
    Uri.parse(bucketUrl),
    body: image.readAsBytesSync(),
    headers: {
      'Content-Type': 'image/jpeg',
      'Authorization': token,
    },
  );
  if (response.statusCode == 200) {
    return null;
  }
  return null;
}

Future<void> deleteNotification(String id) async {
  await Firestore.instance
      .collection(fireBaseCollections.notifications)
      .document(id)
      .delete();
}

Future addProduct(Map<String, dynamic> data) async {
  await Firestore.instance
      .collection(fireBaseCollections.products)
      .add(data)
      .then((value) => Firestore.instance
              .collection(fireBaseCollections.products)
              .document(value.id)
              .update({
            'productId': value.id,
          }));
}

Future<String?> uploadImage(List<int> data, String path) async {
  final String bucket = 'webkit-5cc0f.appspot.com';
  final String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

  final String uploadUrl =
      'https://firebasestorage.googleapis.com/v0/b/$bucket/o?name=$path%2F$fileName';

  try {
    final response = await http.post(
      Uri.parse(uploadUrl),
      headers: {
        'Content-Type': 'application/octet-stream',
      },
      body: data,
    );

    if (response.statusCode == 200) {
      String downloadUrl =
          "https://firebasestorage.googleapis.com/v0/b/webkit-5cc0f.appspot.com/o/$path%2F$fileName?alt=media&token=${jsonDecode(response.body)['downloadTokens']}";

      return downloadUrl;
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}

Future<String?> deleteImage(String path) async {
  try {
    final response = await http.delete(
      Uri.parse(path),
      headers: {
        'Content-Type': 'application/octet-stream',
      },
    );

    if (response.statusCode == 200) {
      return '';
    } else {
      return null;
    }
  } catch (e) {
    return null;
  }
}
