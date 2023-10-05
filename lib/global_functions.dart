import 'dart:io';

import 'package:barrani/global_variables.dart';
import 'package:barrani/models/invitation.dart';
import 'package:barrani/models/product.dart';
import 'package:barrani/models/user.dart';
import 'package:barrani/models/zone.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:barrani/helpers/theme/admin_theme.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

UserModal findUser(String id) {
  return currentUsers.where((user) => user.userId == id).toList().first;
}

UserModal finduserByEmail(String? email) {
  return currentUsers.where((element) => element.email == email).toList().first;
}

UserModal currentUser() {
  return currentUsers
      .where((element) => element.email == userData?.email)
      .toList()
      .first;
}

//message
void showMessage({
  required BuildContext context,
  required String message,
  Color backgroundColor = Colors.black87,
}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            message,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(Duration(seconds: 3), () {
    overlayEntry.remove();
  });
}

// validate time interval
String? validateTimeInterval(
    TimeOfDay startTime, TimeOfDay endTime, int minimumIntervalInMinutes) {
  int startMinutes = startTime.hour * 60 + startTime.minute;
  int endMinutes = endTime.hour * 60 + endTime.minute;

  if (endMinutes - startMinutes >= minimumIntervalInMinutes) {
    return null;
  }
  return 'Time range must be 1 hour minimum';
}

String? validateStartTime(TimeOfDay startTime, TimeOfDay endTime) {
  if (endTime.hour > startTime.hour ||
      (endTime.hour == startTime.hour && endTime.minute >= startTime.minute)) {
    return null;
  }
  return 'الوقت الذي تنتهي فيه يجب أن يكون بعد الوقت الذي تبدأ فيه';
}

String? validateEndTime(TimeOfDay startTime, TimeOfDay endTime) {
  if (endTime.hour > startTime.hour ||
      (endTime.hour == startTime.hour && endTime.minute >= startTime.minute)) {
    return validateTimeInterval(startTime, endTime, 60);
  }
  return 'الوقت الذي تنتهي فيه يجب أن يكون بعد الوقت الذي تبدأ فيه';
}

String? validateInvitationCode(String? value) {
  if (value == null || value.isEmpty) {
    return 'الرجاء إدخال رابط الدعوة';
  }
  if (value == '12345') {
    return 'الرجاء إدخال رابط الدعوة';
  }
  return null;
}

bool isAppointmentExist(DateTime date) {
  return appointments
      .where((e) {
        return date.isAfter(e.startTime) && date.isBefore(e.endTime) ||
            date == e.startTime;
      })
      .toList()
      .isNotEmpty;
}

Appointment getAppointment(String id) {
  return appointments.where((element) => element.id == id).toList().first;
}

List<Appointment> getUserAppointments([String? id, String? status]) {
  String userId = id ?? userData!.userId;
  bool isStatus(String meta) => status == null ? true : meta == status;
  List<Invitation> userInvitations = invitations
      .where(
        (element) =>
            (element.receiverId == userId || element.senderId == userId) &&
            isStatus(
              element.status,
            ),
      )
      .toList();
  return userInvitations.map((e) {
    return getAppointment(e.appointmentId);
  }).toList();
}

bool isUserInvited(DateTime date, String userId) {
  List<Appointment> userAppointments = getUserAppointments(userId, "accept");
  return userAppointments
      .where((element) => isAppointmentExist(date))
      .toList()
      .isNotEmpty;
}

PlaceZone getZone(String id) {
  return zones.where((element) => element.id == id).toList().first;
}

Appointment getAppointmentByDate(DateTime date) {
  return appointments
      .where((e) {
        return date.isAfter(e.startTime) && date.isBefore(e.endTime) ||
            date == e.startTime;
      })
      .toList()
      .first;
}

List<Invitation> getInvitationsByAppointmentId(String id) {
  return invitations.where((element) => element.appointmentId == id).toList();
}

bool isUserInvitedToAppointment(Appointment p) {
  List<Invitation> userInvitations =
      invitations.where((e) => e.appointmentId == p.id.toString()).toList();
  return userInvitations
      .where((element) => element.receiverId == userData?.userId)
      .isNotEmpty;
}

bool isUserAppointmentSender(Appointment p) {
  List<Invitation> userInvitations =
      invitations.where((e) => e.appointmentId == p.id.toString()).toList();
  return userInvitations
      .where((element) => element.senderId == userData?.userId)
      .isNotEmpty;
}

Invitation getAppointedUserInvitation(Appointment p) {
  return invitations
      .where((element) =>
          element.receiverId == userData?.userId &&
          element.appointmentId == p.id.toString())
      .toList()
      .first;
}

Future<XFile?> myPickedFile({required int imageSize}) async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = kIsWeb
      ? await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: imageSize.toDouble(),
          maxHeight: imageSize.toDouble(),
          imageQuality: 100,
        )
      : await picker.pickImage(
          source: ImageSource.gallery,
        );
  return pickedFile;
}

Future<File?> myImportedImg({
  required XFile? pickedFile,
  required int imageSize,
}) async {
  ImageProperties properties =
      await FlutterNativeImage.getImageProperties(pickedFile!.path);
  int? imageWidth = properties.width;
  int? imageHeight = properties.height;
  File compressedFile = await FlutterNativeImage.compressImage(
    pickedFile.path,
    quality: 100,
    targetWidth: imageWidth! >= imageHeight!
        ? imageSize
        : (imageWidth * imageSize / imageHeight).round(),
    targetHeight: imageHeight > imageWidth
        ? imageSize
        : (imageHeight * imageSize / imageWidth).round(),
  );
  File? image = compressedFile;
  return image;
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

Color getStatusColor(String status, ContentTheme contentTheme) {
  switch (status) {
    case 'accepted':
      return contentTheme.success;
    case 'pending':
      return contentTheme.info;
    case 'declined':
      return contentTheme.danger;
    default:
      return contentTheme.cardBackground;
  }
}

Color getStatusBgColor(String status, ContentTheme contentTheme) {
  switch (status) {
    case 'accepted':
      return contentTheme.onSuccess;
    case 'pending':
      return contentTheme.onInfo;
    case 'declined':
      return contentTheme.onDanger;
    default:
      return contentTheme.background;
  }
}

List<Product> sortByDate(List<Product> products) {
  products.sort((a, b) => b.createdDate.compareTo(a.createdDate));
  return products;
}

List<PlaceZone> sortByDateZones(List<PlaceZone> zones) {
  zones.sort((a, b) => b.createdDate!.compareTo(a.createdDate!));
  return zones;
}

Future<String> downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

Future<void> downloadImage(String imageUrl) async {
  final response = await http.get(Uri.parse(imageUrl));

  if (response.statusCode == 200) {
    // Request storage permission
    if (Platform.isAndroid || Platform.isIOS) {
      var status = await Permission.manageExternalStorage.request();

      if (!status.isGranted) {
        throw ('Permission denied for storage.');
      }
    }
    final Directory? directory = await getDownloadsDirectory();
    if (directory!.path.isEmpty) {
      throw ('Folder no found.');
    }

    // Generate a unique filename for the image
    String uniqueFilename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    if (Platform.isIOS || Platform.isAndroid) {
      await FileDownloader.downloadFile(
        url: imageUrl,
        name: uniqueFilename,
        notificationType: NotificationType.all,
      );
    } else {
      // Combine the directory and filename to create the full path
      String fullPath = "${directory.path}/$uniqueFilename";

      final Uint8List bytes = response.bodyBytes;
      File file = File(fullPath);

      try {
        // Save the image file to the specified location, overwriting any existing file
        await file.writeAsBytes(bytes);
      } catch (e) {
        throw ('Failed to save image: $e');
      }
    }
  } else {
    throw ('Failed to download image. Status code: ${response.statusCode}');
  }
}
