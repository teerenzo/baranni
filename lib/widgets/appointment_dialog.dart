import 'dart:io';
import 'package:barrani/app_constant.dart';
import 'package:barrani/constants.dart';
import 'package:barrani/global_functions.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/extensions/date_time_extention.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/services/appointment_services.dart';
import 'package:barrani/helpers/services/appointment_web_services.dart';
import 'package:barrani/helpers/theme/app_style.dart';
import 'package:barrani/helpers/theme/app_theme.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_flex.dart';
import 'package:barrani/helpers/widgets/my_flex_item.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/my_text_style.dart';
import 'package:barrani/models/appointment.dart';
import 'package:barrani/models/user.dart';
import 'package:barrani/models/zone.dart';
import 'package:bottom_picker/bottom_picker.dart';
import 'package:bottom_picker/resources/arrays.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:image_picker/image_picker.dart';

class AppointmentDialog extends ConsumerStatefulWidget {
  final bool isMobile;
  final DateTime startDate;
  const AppointmentDialog({
    super.key,
    required this.isMobile,
    required this.startDate,
  });

  @override
  ConsumerState<AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends ConsumerState<AppointmentDialog>
    with UIMixin {
  List<UserModal> invites = [];
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  bool isSubmitting = false;
  bool isSubmitted = false;
  PlaceZone? placeZone;
  XFile? thumbNail;
  String description = '';
  File? image;
  Uint8List? webImage;

  void modifyInvites(UserModal user) {
    if (isSubmitting) {
      return;
    }
    if (!isInvited(user)) {
      setState(() {
        invites.add(user);
      });
    } else {
      setState(() {
        invites = invites.where((e) => e.userId != user.userId).toList();
      });
    }
    filterUser();
  }

  bool isInvited(UserModal user) {
    return invites.where((element) => element.userId == user.userId).isNotEmpty;
  }

  Future<void> handleSubmit() async {
    setState(() {
      isSubmitted = true;
    });
    if (validateTime() != null ||
        validateZone() != null ||
        invites.isEmpty ||
        isAppointmentExist(widget.startDate.applied(startTime)) ||
        isAppointmentExist(widget.startDate.applied(endTime)) ||
        validateDescription(description) != null) {
      return;
    }
    setState(() {
      isSubmitting = true;
    });

    try {
      // var imageUrl = await uploadThumbnail(image!);
      // if (imageUrl == null) {
      //   setState(() {
      //     isSubmitting = false;
      //   });
      //   return;
      // }

      Appointment p = Appointment(
        startTime: widget.startDate.applied(startTime),
        endTime: widget.startDate.applied(endTime),
        location: placeZone!.id,
        subject: placeZone!.name,
        notes: description,
      );
      Map<String, dynamic> data = toMap(p);
      invites.add(userData!);

      data['attendees'] = invites
          .map((e) => {
                'email': e.email,
                'names': e.names,
                'role': e.role,
                'userId': e.userId,
                'status': 'pending',
                'isCreator': e.userId == userData?.userId,
              })
          .toList();
      if (kIsWeb) {
        String pId = await webAddAppointment(data);
        for (var user in invites) {
          webSendInvitation(user.userId, pId, 'pending', {
            'startTime': widget.startDate.applied(startTime),
            'endTime': widget.startDate.applied(endTime),
            'location': placeZone!.id,
            'subject': placeZone!.name,
          }).then((value) async {
            await sendNotification(
              'You have been invited',
              'You have been invited to ${placeZone!.name}',
              user.userId,
            );
          });
        }
      } else {
        String pId = await addAppointment(data);
        for (var user in invites) {
          sendInvitation(user.userId, pId, 'pending', {
            'startTime': widget.startDate.applied(startTime),
            'endTime': widget.startDate.applied(endTime),
            'location': placeZone!.id,
            'subject': placeZone!.name,
          }).then((value) async {
            await sendNotification(
              'Appointment invitation',
              '${userData?.names} has invited you to ${placeZone!.name}',
              user.userId,
            );
          });
        }
      }
      setState(() {
        isSubmitting = false;
      });
      Navigator.pop(context);
    } catch (error) {}
  }

  String? validateTime() {
    if (validateStartTime(startTime, endTime) != null ||
        validateEndTime(startTime, endTime) != null) {
      return 'Time range must be 1 hour minimum';
    } else {
      return null;
    }
  }

  String? validateZone() {
    return placeZone == null ? 'Zone is required' : null;
  }

  String? validateDescription(String value) {
    if (value.isEmpty) {
      return 'Description is required';
    } else if (value.length > 300) {
      return 'Description must not be more than 300 characters';
    }
    return null;
  }

  void filterUser() {
    List<UserModal> filteredUsers = invites.where((element) {
      return !isUserInvited(
              widget.startDate.applied(startTime), element.userId) &&
          !isUserInvited(widget.startDate.applied(endTime), element.userId) &&
          element.userId != userData?.userId;
    }).toList();
    setState(() {
      invites = filteredUsers;
    });
  }

  Future<void> myImagePicker({
    required int imageSize,
  }) async {
    final XFile? pickedFile = await myPickedFile(
      imageSize: imageSize,
    );
    if (pickedFile != null) {
      if (kIsWeb) {
        webImage = await pickedFile.readAsBytes();
      } else {
        image = await myImportedImg(
          pickedFile: pickedFile,
          imageSize: imageSize,
        );
      }
      setState(() {});
    } else {
      // importation error
    }
  }

  @override
  void initState() {
    super.initState();
    startTime = TimeOfDay(
      hour: widget.startDate.hour,
      minute: widget.startDate.minute,
    );
    endTime = TimeOfDay(
      hour: widget.startDate.hour + 2,
      minute: widget.startDate.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentUsersStream = ref.watch(kIsWeb
        ? FirebaseWebHelper.allUsersStreamProvider
        : allUsersStreamProvider);
    var placeZones = ref.watch(kIsWeb
        ? FirebaseWebHelper.allZonesStreamProvider
        : allZonesStreamProvider);
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width * (widget.isMobile ? 1 : 0.4),
        height: widget.isMobile ? MediaQuery.of(context).size.height : 760,
        padding: EdgeInsets.only(
          left: widget.isMobile ? 16 : 0,
          right: widget.isMobile ? 16 : 0,
          top: widget.isMobile ? 24 : 0,
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: [
                MySpacing.height(16),
                Row(
                  children: [
                    MyText.bodyMedium(
                      "Date",
                      fontWeight: 600,
                      muted: true,
                      textAlign: TextAlign.start,
                    ),
                    MySpacing.width(66),
                    MyText.bodyMedium(
                      dateFormatter.format(widget.startDate),
                      fontWeight: 600,
                      muted: true,
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
                MySpacing.height(16),
                Row(
                  children: [
                    MyText.bodyMedium(
                      "Select Zone",
                      fontWeight: 600,
                      muted: true,
                      textAlign: TextAlign.start,
                    ),
                    MySpacing.width(16),
                    placeZones
                        .whenData((value_) => PopupMenuButton(
                              onSelected: (value) {
                                setState(() {
                                  placeZone = value;
                                });
                              },
                              itemBuilder: (BuildContext context) {
                                return value_.map((zone) {
                                  return PopupMenuItem(
                                    value: zone,
                                    height: 32,
                                    child: MyText.bodySmall(
                                      zone.name,
                                      color: theme.colorScheme.onBackground,
                                      fontWeight: 600,
                                    ),
                                  );
                                }).toList();
                              },
                              color: theme.cardTheme.color,
                              child: MyContainer.bordered(
                                padding: MySpacing.xy(8, 8),
                                child: Row(
                                  children: <Widget>[
                                    MyText.labelMedium(
                                      placeZone != null
                                          ? placeZone!.name
                                          : 'Tap Select',
                                      color: theme.colorScheme.onBackground,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(left: 4),
                                      child: Icon(
                                        LucideIcons.chevronDown,
                                        size: 22,
                                        color: theme.colorScheme.onBackground,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ))
                        .when(
                          loading: () => Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (error, stack) => MyText.bodyMedium(
                            'Error loading zones',
                            fontWeight: 600,
                            muted: true,
                            color: kAlertColor,
                            textAlign: TextAlign.start,
                          ),
                          data: (Widget appointmentData) {
                            return appointmentData;
                          },
                        ),
                  ],
                ),
                MySpacing.height(16),
                if (isSubmitted && validateZone() != null)
                  Container(
                    alignment: Alignment.centerLeft,
                    child: MyText.bodyMedium(
                      validateZone() ?? '',
                      fontWeight: 600,
                      muted: true,
                      color: kAlertColor,
                      textAlign: TextAlign.start,
                    ),
                  ),
                if (isSubmitted && validateZone() != null) MySpacing.height(16),
                Row(
                  children: [
                    MyText.bodyMedium(
                      "Thumbnail",
                      fontWeight: 600,
                      muted: true,
                      textAlign: TextAlign.start,
                    ),
                    MySpacing.width(16),
                    MyButton.outlined(
                      onPressed: () {
                        myImagePicker(
                          imageSize: 1000,
                        );
                      },
                      borderColor: image != null
                          ? Colors.transparent
                          : contentTheme.secondary,
                      padding:
                          image != null ? MySpacing.zero : MySpacing.xy(16, 16),
                      child: image != null
                          ? Image(
                              image: FileImage(image!),
                              width: 50,
                            )
                          : MyText.labelMedium(
                              'Select Thumbnail',
                              fontWeight: 600,
                            ),
                    )
                  ],
                ),
                MySpacing.height(16),
                if (isSubmitted && image == null)
                  Container(
                    alignment: Alignment.centerLeft,
                    child: MyText.bodyMedium(
                      'thumbnail is required',
                      fontWeight: 600,
                      muted: true,
                      color: kAlertColor,
                      textAlign: TextAlign.start,
                    ),
                  ),
                if (isSubmitted && image == null) MySpacing.height(16),

                Container(
                  alignment: Alignment.centerLeft,
                  child: MyText.bodyMedium(
                    "Invites",
                    fontWeight: 600,
                    muted: true,
                    textAlign: TextAlign.start,
                  ),
                ),

                MySpacing.height(8),
                SizedBox(
                  height: 90,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: currentUsersStream
                        .whenData((value) => currentUsers
                            .where(
                                (element) => element.userId != userData?.userId)
                            .map((e) => InviteAvatar(
                                  user: e,
                                  isInvited: isInvited(e),
                                  isMobile: widget.isMobile,
                                  onTap: () {
                                    modifyInvites(e);
                                  },
                                ))
                            .toList())
                        .when(
                          loading: () => [
                            Center(
                              child: CircularProgressIndicator(),
                            )
                          ],
                          error: (error, stack) => [
                            Center(
                              child: MyText.bodyMedium(
                                'Error loading users $error',
                                fontWeight: 600,
                                muted: true,
                                color: kAlertColor,
                                textAlign: TextAlign.start,
                              ),
                            )
                          ],
                          data: (List<InviteAvatar> data) {
                            return data;
                          },
                        ),
                  ),
                ),
                SizedBox(height: 16),
                if (isSubmitted && invites.isEmpty)
                  StreamBuilder<Object>(
                      stream: null,
                      builder: (context, snapshot) {
                        return SizedBox(
                          width: double.infinity,
                          child: MyText.bodyMedium(
                            'At least one influencer must be invited',
                            fontWeight: 600,
                            muted: true,
                            color: kAlertColor,
                            textAlign: TextAlign.start,
                          ),
                        );
                      }),
                MySpacing.height(8),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: MyText.bodyMedium(
                          "Description",
                          fontWeight: 600,
                          muted: true,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      TextFormField(
                        maxLines: 3,
                        onChanged: (value) {
                          setState(() {
                            description = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Appointment Description",
                          hintStyle: MyTextStyle.bodySmall(xMuted: true),
                          border: outlineInputBorder,
                          enabledBorder: outlineInputBorder,
                          focusedBorder: focusedInputBorder,
                          contentPadding: MySpacing.all(16),
                          isCollapsed: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                      ),
                      if (isSubmitted &&
                          validateDescription(description) != null)
                        SizedBox(
                          width: double.infinity,
                          child: MyText.bodyMedium(
                            validateDescription(description) ?? '',
                            fontWeight: 600,
                            muted: true,
                            color: kAlertColor,
                            textAlign: TextAlign.start,
                          ),
                        ),
                    ],
                  ),
                ),
                MySpacing.height(16),
                MyFlex(
                  contentPadding: false,
                  children: [
                    MyFlexItem(
                      sizes: "lg-6",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.bodyMedium(
                            "Start Time",
                            fontWeight: 600,
                            muted: true,
                          ),
                          MySpacing.height(8),
                          MyContainer.bordered(
                            paddingAll: 12,
                            onTap: () async {
                              if (isSubmitting) {
                                return;
                              }
                              if (widget.isMobile) {
                                bottomTimePicker(context,
                                    widget.startDate.applied(startTime),
                                    (date) {
                                  setState(() {
                                    startTime = TimeOfDay(
                                        hour: date.hour, minute: date.minute);
                                  });

                                  filterUser();
                                });
                              } else {
                                TimeOfDay? t =
                                    await pickTime(context, startTime);
                                if (t != null) {
                                  setState(() {
                                    startTime = t;
                                  });
                                  filterUser();
                                }
                              }
                            },
                            borderColor: theme.colorScheme.secondary,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  LucideIcons.calendar,
                                  color: theme.colorScheme.secondary,
                                  size: 16,
                                ),
                                MySpacing.width(10),
                                MyText.bodyMedium(
                                  timeHourFormatter.format(
                                    widget.startDate.applied(startTime),
                                  ),
                                  fontWeight: 600,
                                  color: theme.colorScheme.secondary,
                                ),
                              ],
                            ),
                          ),
                          if (isAppointmentExist(
                                  widget.startDate.applied(startTime)) &&
                              isSubmitted)
                            MyText.bodyMedium(
                              'This Time is occupied',
                              fontWeight: 600,
                              muted: true,
                              color: kAlertColor,
                              textAlign: TextAlign.start,
                            ),
                        ],
                      ),
                    ),
                    MyFlexItem(
                      sizes: "lg-6",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.bodyMedium(
                            "End Time",
                            fontWeight: 600,
                            muted: true,
                          ),
                          MySpacing.height(8),
                          MyContainer.bordered(
                            paddingAll: 12,
                            onTap: () async {
                              if (isSubmitting) {
                                return;
                              }
                              if (widget.isMobile) {
                                bottomTimePicker(
                                    context, widget.startDate.applied(endTime),
                                    (date) {
                                  setState(() {
                                    endTime = TimeOfDay(
                                        hour: date.hour, minute: date.minute);
                                  });
                                });
                              } else {
                                TimeOfDay? t = await pickTime(context, endTime);
                                if (t != null) {
                                  setState(() {
                                    endTime = t;
                                  });
                                  filterUser();
                                }
                              }
                            },
                            borderColor: theme.colorScheme.secondary,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Icon(
                                  LucideIcons.calendar,
                                  color: theme.colorScheme.secondary,
                                  size: 16,
                                ),
                                MySpacing.width(10),
                                MyText.bodyMedium(
                                  timeHourFormatter.format(
                                    widget.startDate.applied(endTime),
                                  ),
                                  fontWeight: 600,
                                  color: theme.colorScheme.secondary,
                                ),
                              ],
                            ),
                          ),
                          if (isAppointmentExist(
                                  widget.startDate.applied(endTime)) &&
                              isSubmitted)
                            MyText.bodyMedium(
                              'This Time is occupied',
                              fontWeight: 600,
                              muted: true,
                              color: kAlertColor,
                              textAlign: TextAlign.start,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                if (isSubmitted && validateTime() != null)
                  MyText.bodyMedium(
                    validateTime()!,
                    fontWeight: 600,
                    muted: true,
                    color: kAlertColor,
                    textAlign: TextAlign.start,
                  ),
                // action buttons
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: MyButton.block(
                          backgroundColor: theme.colorScheme.error,
                          borderRadiusAll: AppStyle.buttonRadius.medium,
                          elevation: 0,
                          onPressed: () {
                            if (isSubmitting) {
                              return;
                            }
                            Navigator.of(context).pop();
                          },
                          child: MyText.bodyLarge(
                            'Cancel',
                            fontWeight: 600,
                            color: theme.colorScheme.onError,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: MyButton.block(
                          backgroundColor: theme.colorScheme.primary
                              .withOpacity(isSubmitting ? 0.8 : 1),
                          borderRadiusAll: AppStyle.buttonRadius.medium,
                          elevation: 0,
                          onPressed: () {
                            handleSubmit();
                          },
                          child: MyText.bodyLarge(
                            isSubmitting ? 'Submitting' : 'Submit',
                            fontWeight: 600,
                            color: theme.colorScheme.onError,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  buildTextField(String fieldTitle, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(
          fieldTitle,
        ),
        MySpacing.height(8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: MyTextStyle.bodySmall(xMuted: true),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1,
                  strokeAlign: 0,
                  color: theme.colorScheme.onBackground.withAlpha(80)),
            ),
            contentPadding: MySpacing.all(16),
            isCollapsed: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
        ),
      ],
    );
  }
}

class InviteAvatar extends StatelessWidget {
  final UserModal user;
  final bool isInvited;
  final bool isMobile;
  final Function() onTap;
  const InviteAvatar({
    Key? key,
    required this.user,
    this.isInvited = false,
    this.isMobile = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyButton(
      onPressed: onTap,
      elevation: 0,
      borderRadiusAll: 60,
      borderColor: theme.shadowColor,
      padding: const EdgeInsets.all(0),
      backgroundColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Column(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(60),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Opacity(
                  opacity: isInvited ? 0.6 : 1,
                  child: MyContainer.rounded(
                    height: 60,
                    width: 60,
                    paddingAll: 0,
                    color: Colors.transparent,
                    child: user.photoUrl != ''
                        ? Image.network(
                            user.photoUrl,
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: MyText.labelLarge(user.names[0]),
                          ),
                  ),
                ),
                if (isInvited)
                  Icon(
                    Icons.done,
                    color: kSecondaryColor,
                  )
              ],
            ),
          ),
          Container(
            width: 80,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 5),
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: MyText.bodyMedium(
              user.names.split(' ')[0],
              fontWeight: 600,
              muted: true,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

Future<TimeOfDay?> pickTime(BuildContext context, TimeOfDay initialTime) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: initialTime,
    initialEntryMode: TimePickerEntryMode.dialOnly,
  );
  return picked;
}

void bottomTimePicker(
    BuildContext context, DateTime initialDate, Function(DateTime) callback) {
  BottomPicker.time(
    title: 'Set your next meeting time',
    titleAlignment: CrossAxisAlignment.center,
    titlePadding: EdgeInsets.only(top: 15),
    titleStyle: theme.textTheme.labelMedium!,
    backgroundColor: theme.dialogBackgroundColor,
    dismissable: true,
    iconColor: theme.indicatorColor,
    initialDateTime: initialDate,
    pickerTextStyle: theme.textTheme.displayMedium!,
    buttonText: 'Select',
    buttonTextStyle: TextStyle(
      color: theme.colorScheme.onError,
      fontWeight: FontWeight.w700,
    ),
    buttonSingleColor: theme.colorScheme.primary,
    closeIconColor: theme.primaryColorLight,
    displayButtonIcon: false,
    buttonWidth: MediaQuery.of(context).size.width * 0.8,
    buttonPadding: 16,
    onSubmit: (date) {
      callback(date);
    },
    bottomPickerTheme: BottomPickerTheme.orange,
    use24hFormat: false,
  ).show(context);
}
