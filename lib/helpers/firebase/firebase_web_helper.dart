import 'dart:async';

import 'package:barrani/constants.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/config.dart';
import 'package:barrani/helpers/storage/local_storage.dart';
import 'package:barrani/models/ChatAppointment.dart';
import 'package:barrani/models/ChatInvitation.dart';
import 'package:barrani/models/GroupChat.dart';
import 'package:barrani/models/IndividualChat.dart';
import 'package:barrani/models/appointment.dart';
import 'package:barrani/models/invitation.dart';
import 'package:barrani/models/kanban.dart';
import 'package:barrani/models/notification.dart';
import 'package:barrani/models/projects.dart';
import 'package:barrani/models/user.dart';
import 'package:barrani/models/zone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

abstract class FirebaseWebHelper {
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: Config.firebaseIosApiKey,
        projectId: Config.firebaseProjectId,
        storageBucket: Config.firebaseStorageBucket,
        messagingSenderId: Config.firebaseMessagingSenderId,
        appId: Config.firebaseIosAppId,
      ),
    );
  }

  static Future<bool> isValidInvitationCode(String code) async {
    var snapshot = await FirebaseFirestore.instance
        .collection(fireBaseCollections.userInvitations)
        .where('invitation', isEqualTo: code)
        .get();
    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs.first.data();

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

  static Future<void> signUp({
    required String email,
    required String password,
    required String invitationCode,
  }) async {
    try {
      var isValidCode = await isValidInvitationCode(invitationCode);

      if (!isValidCode) {
        throw Error();
      }
      if (isValidCode) {
        var user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (user.user != null) {
          var invitation = await FirebaseFirestore.instance
              .collection(fireBaseCollections.userInvitations)
              .where('invitation', isEqualTo: invitationCode)
              .get();

          await FirebaseFirestore.instance
              .collection(fireBaseCollections.userInvitations)
              .doc(invitation.docs.first.id)
              .update({'isUsed': true});

          // save user data to firestore
          await FirebaseFirestore.instance
              .collection('${'users'}/${user.user?.uid}')
              .add({
            'email': email,
            'names': invitation.docs.first['names'],
            'invitationCode': invitationCode,
            'userId': user.user!.uid,
            'role': invitation.docs.first['userType']
          });
        } else {
          throw Error();
        }
      } else {
        throw Error();
      }
    } catch (e) {
      throw Error();
    }
  }

  static Future<User?> signIn(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return FirebaseAuth.instance.currentUser!;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static bool isLoggedUser() {
    return FirebaseAuth.instance.currentUser != null;
  }

  static Future<void> onCreateKanbanProject({
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
    await FirebaseFirestore.instance
        .collection(fireBaseCollections.project)
        .add(data);
  }

  static Future<void> onUpdateKanbanProject({
    required String? projectId,
    required String status,
  }) async {
    // Construct the document data
    // Submit to Firestore
    await FirebaseFirestore.instance
        .collection(fireBaseCollections.project)
        .doc(projectId!)
        .update({'status': status});
  }

  // static Future<String?> uploadWebImageToFirebase(dynamic imageFile) async {
  //   if (imageFile == null) return null;

  //   Reference reference;

  //   final data = UriData.fromUri(Uri.parse(imageFile.path)).contentAsBytes();
  //   reference = FirebaseStorage.instance
  //       .ref()
  //       .child('profile_images/${DateTime.now().toIso8601String()}.png');
  //   UploadTask uploadTask = reference.putData(
  //     data,
  //     SettableMetadata(
  //       contentType: 'image/png',
  //     ),
  //   );
  //   TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});

  //   if (snapshot.state != TaskState.success) {
  //     print('Error while uploading image: ${snapshot.state}');
  //     return null;
  //   }

  //   return await reference.getDownloadURL();
  // }

  static Future<String?> uploadWebImageToFirebase(XFile imageFile) async {
    Reference reference;

    // Read the file as bytes
    List<int> data = await imageFile.readAsBytes();

    reference = FirebaseStorage.instance
        .ref()
        .child('profile_images/${DateTime.now().toIso8601String()}.png');
    UploadTask uploadTask = reference.putData(
      data as Uint8List,
      SettableMetadata(
        contentType: 'image/png',
      ),
    );
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});

    if (snapshot.state != TaskState.success) {
      return null;
    }

    return await reference.getDownloadURL();
  }

  static Future<void> onWebSavePressed(
      String firstName, String lastName, String? imageUrl) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userData?.userId)
        .update({
      'names': firstName,
      if (imageUrl != null)
        'profile_url': imageUrl, // Only update imageUrl if it's not null
    });
  }

  static Future<bool> isEmailExist({required String email}) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection(fireBaseCollections.users)
          .where('email', isEqualTo: email)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint(e.toString());
      throw Error();
    }
  }

  static Future<void> forgotPassword({required String email}) async {
    try {
      bool isEmailExist = await FirebaseWebHelper.isEmailExist(email: email);
      if (!isEmailExist) {
        throw Error();
      }
      if (isEmailExist) {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        Get.snackbar(
          'Success',
          'Password reset email sent, check your email to reset your password',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      throw Error();
    }
  }

  static Future findAll({required String dbRef}) async {
    try {
      List data = [];
      final CollectionReference collectionRef =
          FirebaseFirestore.instance.collection(dbRef);

      await collectionRef.get().then((value) {
        for (var element in value.docs) {
          data.add(element.data());
        }
      });
      return data;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<void> onSavePressed(String? userId, String firstName,
      String lastName, String? imageUrl) async {
    await FirebaseFirestore.instance
        .collection(fireBaseCollections.users)
        .doc(userId!)
        .update({
      'names': firstName,
      if (imageUrl != null)
        'profile_url': imageUrl, // Only update imageUrl if it's not null
    }).then((value) async {
      var userData_ = UserModal.fromJSON({
        'email': userData!.email,
        'names': firstName,
        'userId': userData!.userId,
        'profile_url': imageUrl,
        'role': userData!.role
      });
      userData = userData_;
      await LocalStorage.storeUserdata(userData_);
    });
  }

  static Future findOne({required String dbRef, required String id}) async {
    try {
      List data = [];
      data = await findAll(dbRef: dbRef) as List;
      return data.where((element) => element['userId'] == id);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future create(
      {required String dbRef, required Map<String, dynamic> data}) async {
    try {
      final CollectionReference collectionRef =
          FirebaseFirestore.instance.collection(dbRef);

      await collectionRef.add(data);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future update(
      {required String dbRef,
      required String id,
      required Map<String, dynamic> data}) async {
    try {
      final DocumentReference documentRef =
          FirebaseFirestore.instance.collection(dbRef).doc(id);

      await documentRef.update(data);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future delete({required String dbRef, required String id}) async {
    try {
      final DocumentReference documentRef =
          FirebaseFirestore.instance.collection(dbRef).doc(id);

      await documentRef.delete();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  // Logout function
  static Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await LocalStorage.removeUserData();
    userData = null;
  }

  static Future deleteAll({required String dbRef}) async {
    try {
      final CollectionReference collectionRef =
          FirebaseFirestore.instance.collection(dbRef);

      await collectionRef.get().then((value) {
        for (var element in value.docs) {
          element.reference.delete();
        }
      });
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getUserById(String id) async {
    DocumentSnapshot result = await FirebaseFirestore.instance
        .collection(fireBaseCollections.users)
        .doc(id)
        .get();
    if (result.exists) {
      return result.data() as Map<String, dynamic>;
    }
    return null;
  }

  static final allUsersStreamProvider = StreamProvider<List<UserModal>>((ref) {
    CollectionReference fireStoreQuery =
        FirebaseFirestore.instance.collection(fireBaseCollections.users);

    return fireStoreQuery.snapshots().map((querySnapshot) {
      List<UserModal> currentUsers_ = [];

      for (var element in querySnapshot.docs) {
        Map<String, dynamic> element_ = element.data() as Map<String, dynamic>;
        element_['id'] = element.id;
        currentUsers_.add(UserModal.fromJSON(element_));
      }

      currentUsers = currentUsers_;
      return currentUsers_;
    });
  });

  static final kanbanProjectsProvider =
      StreamProvider<List<KanbanProject>>((ref) {
    CollectionReference fireStoreQuery = FirebaseFirestore.instance.collection(
        fireBaseCollections
            .project); // Assuming your kanban projects are in a collection named 'projects'

    return fireStoreQuery.snapshots().map((querySnapshot) {
      List<KanbanProject> currentProjects_ = [];

      for (var element in querySnapshot.docs) {
        Map<String, dynamic> element_ = element.data() as Map<String, dynamic>;
        element_['id'] = element.id;
        currentProjects_.add(KanbanProject.fromMap(element_));
      }

      return currentProjects_;
    });
  });

  static final projectsProvider = StreamProvider<List<Projects>>((ref) {
    CollectionReference fireStoreQuery = FirebaseFirestore.instance.collection(
        fireBaseCollections
            .projects); // Assuming your kanban projects are in a collection named 'projects'

    return fireStoreQuery.snapshots().map((querySnapshot) {
      List<Projects> currentProjects_ = [];

      for (var element in querySnapshot.docs) {
        Map<String, dynamic> element_ = element.data() as Map<String, dynamic>;
        element_['id'] = element.id;
        currentProjects_.add(Projects.fromMap(element_));
      }

      return currentProjects_;
    });
  });

  static final allAppointmentsStreamProvider =
      StreamProvider<List<Appointment>>((ref) {
    CollectionReference fireStoreQuery =
        FirebaseFirestore.instance.collection(fireBaseCollections.appointments);

    return fireStoreQuery.snapshots().map((querySnapshot) {
      List<Appointment> appointments_ = [];

      for (var element in querySnapshot.docs) {
        Map<String, dynamic> element_ = element.data() as Map<String, dynamic>;
        element_['id'] = element.id;
        appointments_.add(fromMap(element_));
      }
      appointments = appointments_;
      return appointments_;
    });
  });

  static final fetchGroupData = StreamProvider<List<ChatInvitation>>((ref) {
    CollectionReference fireStoreQuery =
        FirebaseFirestore.instance.collection(fireBaseCollections.invitations);
    return fireStoreQuery.snapshots().map((QuerySnapshot event) {
      List<ChatInvitation> invitations_ = [];

      for (var element in event.docs) {
        String appointmentId = element['appointment_id'];

        Timestamp endTime = element['appointment_info']['endTime'];
        DateTime endDate = endTime.toDate();

        Timestamp startTime = element['appointment_info']['startTime'];
        DateTime startDate = startTime.toDate();
        // Check if appointment ID is already added to avoid duplication

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

        if (invitations_
            .every((invitation) => invitation.appointmentId != appointmentId)) {
          invitations_.add(invitation);
        }
      }

      return invitations_
          .where((element) => (element.receiverId == userData!.userId ||
              element.senderId == userData!.userId))
          .toList();
    });
  });

  static final streamGroupChat = StreamProvider<List<GroupChat>>((ref) {
    try {
      return FirebaseFirestore.instance
          .collection('chatMessages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map(
        (querySnapshot) {
          List<GroupChat> groupChats = [];

          for (var element in querySnapshot.docs) {
            Timestamp date = element['timestamp'];
            DateTime sentDate = date.toDate();
            GroupChat groupChat = GroupChat(
              element['senderId'],
              element['text'],
              sentDate,
              element['senderId'],
              element['appointmentId'],
              element['senderId'] == userData!.userId ? true : false,
              element.data().containsKey("type") ? element['type'] : 'text',
            );
            groupChats.add(groupChat);
          }

          return groupChats;
        },
      );
    } catch (e) {
      return Stream.value([]);
    }
  });

  static final streamIndividualChat = StreamProvider<List<Messages>>((ref) {
    try {
      return FirebaseFirestore.instance
          .collection('messages')
          .orderBy("timestamp", descending: false)
          .snapshots()
          .map(
        (querySnapshot) {
          List<Messages> messages = [];

          for (var element in querySnapshot.docs) {
            Timestamp date = element['timestamp'];
            DateTime sentDate = date.toDate();
            Messages individualChat = Messages(
              message: element['message'],
              senderId: element['senderId'],
              timestamp: sentDate,
              username: element['names'],
              receiverId: element['receiverId'],
              chatId:
                  element.data().containsKey('chatId') ? element['chatId'] : '',
              type: element.data().containsKey('type') ? element['type'] : '',
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

  static final fetchSameGroupAttendees =
      StreamProvider<List<Attendees>>((ref) async* {
    try {
      final query = FirebaseFirestore.instance.collection('invitations');

      final bySender =
          await query.where("sender_id", isEqualTo: userData!.userId).get();
      final byReceiver =
          await query.where("receiver_id", isEqualTo: userData!.userId).get();

      List<DocumentSnapshot> documents = [...byReceiver.docs, ...bySender.docs];

      List<Attendees> attendees = [];
      List<ChatAppointment> appointments = [];

      for (var element in documents) {
        final appointmentId = element['appointment_id'];

        final appointment = await FirebaseFirestore.instance
            .collection('appointments')
            .doc(appointmentId)
            .get();

        for (var item in appointment['attendees']) {
          if (userData!.userId == item['userId']) continue;

          final user = await FirebaseFirestore.instance
              .collection('users')
              .doc(item['userId'])
              .get();

          if (attendees
              .every((attendee) => attendee.userId != item['userId'])) {
            attendees.add(Attendees(
                userId: item['userId'],
                email: user['email'],
                names: item['names'],
                role: user['role'],
                profile_url: user.data()!.containsKey('profile_url')
                    ? user['profile_url']
                    : ''));
          }
        }
        Timestamp startDateTimeStamp = appointment['startTime'];

        Timestamp endDateTimeStamp = appointment['endTime'];

        DateTime startDate = startDateTimeStamp.toDate();

        DateTime endDate = endDateTimeStamp.toDate();
        appointments.add(ChatAppointment(
          endTime: endDate,
          startTime: startDate,
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

  static final allInvitationsStreamProvider =
      StreamProvider<List<Invitation>>((ref) {
    CollectionReference fireStoreQuery =
        FirebaseFirestore.instance.collection(fireBaseCollections.invitations);

    return fireStoreQuery.snapshots().map((querySnapshot) {
      List<Invitation> invitations_ = [];

      for (var element in querySnapshot.docs) {
        Map<String, dynamic> element_ = element.data() as Map<String, dynamic>;
        element_['id'] = element.id;
        invitations_.add(Invitation.fromJSON(element_));
      }
      invitations = invitations_;
      return invitations_;
    });
  });

  static final allZonesStreamProvider = StreamProvider<List<PlaceZone>>((ref) {
    CollectionReference fireStoreQuery =
        FirebaseFirestore.instance.collection(fireBaseCollections.zones);

    return fireStoreQuery.snapshots().map((querySnapshot) {
      List<PlaceZone> zones_ = [];

      for (var element in querySnapshot.docs) {
        Map<String, dynamic> element_ = element.data() as Map<String, dynamic>;
        element_['id'] = element.id;
        element_['createdDate'] = element_['createdDate'].toDate();
        zones_.add(PlaceZone.fromJson(element_));
      }
      zones = zones_;
      return zones_;
    });
  });

  static final userNotificationsStreamProvider =
      StreamProvider<List<NotificationModal>>((ref) {
    CollectionReference fireStoreQuery = FirebaseFirestore.instance
        .collection(fireBaseCollections.notifications);
    try {
      return fireStoreQuery.snapshots().map((querySnapshot) {
        List<NotificationModal> notifications_ = [];

        for (var element in querySnapshot.docs) {
          Map<String, dynamic> element_ =
              element.data() as Map<String, dynamic>;
          element_['id'] = element.id;
          if (element_['userId'] == userData!.userId) {
            notifications_.add(NotificationModal.fromJson(element_));
          }
        }
        notifications = notifications_;
        return notifications_;
      });
    } catch (e) {
      print(e);
      return Stream.value([]);
    }
  });

  static Future deleteNotification(String id) async {
    await FirebaseFirestore.instance
        .collection(fireBaseCollections.notifications)
        .doc(id)
        .delete();
  }

  static Future readNotification(String id) async {
    await FirebaseFirestore.instance
        .collection(fireBaseCollections.notifications)
        .doc(id)
        .update({
      'isRead': true,
    });
  }

  static Future addProduct(Map<String, dynamic> data) async {
    await FirebaseFirestore.instance
        .collection(fireBaseCollections.products)
        .add(data)
        .then((value) => FirebaseFirestore.instance
                .collection(fireBaseCollections.products)
                .doc(value.id)
                .update({
              'productId': value.id,
            }));
  }

  static Future<String?> uploadFile(List<int> data, String path) async {
    Reference reference;
    reference = FirebaseStorage.instance
        .ref()
        .child('$path/${DateTime.now().toIso8601String()}.png');
    UploadTask uploadTask = reference.putData(
      data as Uint8List,
      SettableMetadata(
        contentType: 'image/png',
      ),
    );
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => {});

    if (snapshot.state != TaskState.success) {
      return null;
    }
    return await reference.getDownloadURL();
  }

  static Future<void> addZone(String name) async {
    await FirebaseFirestore.instance.collection(fireBaseCollections.zones).add({
      'name': name,
      'userId': userData!.userId,
      'createdDate': DateTime.now(),
    });
  }
}
