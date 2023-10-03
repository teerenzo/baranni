import 'package:appflowy_board/appflowy_board.dart';
import 'package:barrani/models/invitation.dart';
import 'package:barrani/models/notification.dart';
import 'package:barrani/models/user.dart';
import 'package:barrani/models/user_nvitation.dart';
import 'package:barrani/models/zone.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'constants.dart';

List<UserModal> currentUsers = [];
List<Appointment> appointments = [];
List<Invitation> invitations = [];
List<UserInvitation> userInvitations = [];
List<PlaceZone> zones = [];
List<NotificationModal> notifications = [];
List<AppFlowyGroupData> allGroups = []; // Add this line
String selectedKanbanPriority = "Medium";
List<String> userImages = [];
List<UserModal> filteredUsers = [];

UserModal? userData;
//User
XFile? imageFile;

//Responsive property
double screenWidth = 360;
double screenHeight = 600;
double scale = 1;
double imageScale = 1;
double horizontalPadding = kHorizontalPadding;
double textScaleFactor = 1;
double textScale = textScaleFactor;
//Responsive property

//Firestore
FirebaseStorage storage = FirebaseStorage.instance;
