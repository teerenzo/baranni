import 'dart:async';
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
import 'package:barrani/models/kanbanProject.dart';
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

class ProjectDialog extends ConsumerStatefulWidget {
  final bool isMobile;
  final bool isEditing;
  final KanbanProject? kanbanProject;
  final Function(PlaceZone)? onSave;
  const ProjectDialog({
    super.key,
    required this.isMobile,
    this.isEditing = false,
    this.kanbanProject,
    this.onSave,
  });

  @override
  ConsumerState<ProjectDialog> createState() => _ProjectDialogState();
}

class _ProjectDialogState extends ConsumerState<ProjectDialog> with UIMixin {
  List<UserModal> invites = [];
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  bool isSubmitting = false;
  bool isSubmitted = false;
  PlaceZone? placeZone;
  XFile? thumbNail;
  String title = '';
  String description = '';
  XFile? pickedImage;
  String imageUrl = "";
  Uint8List? webImage;

  bool isInvited(UserModal user) {
    return invites.where((element) => element.userId == user.userId).isNotEmpty;
  }

  Future<void> handleSubmit() async {
    if (pickedImage != null) {
      return;
    }
    setState(() {
      isSubmitted = true;
    });
    if (validateDescription(description) != null) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });
    if (widget.isEditing) {
      await FirebaseWebHelper.updateProject(
          widget.kanbanProject!.id!,
          title,
          description,
          imageUrl == "" ? widget.kanbanProject!.thumbnail! : imageUrl);
      setState(() {
        isSubmitting = false;
      });
      Navigator.of(context).pop();
      return;
    } else {
      await FirebaseWebHelper.addProject(
          title, description, imageUrl == "" ? null : imageUrl);
    }

    setState(() {
      isSubmitting = false;
    });
    Navigator.of(context).pop();
  }

  String? validateDescription(String value) {
    if (value.isEmpty) {
      return 'Description is required';
    } else if (value.length > 300) {
      return 'Description must not be more than 300 characters';
    }
    return null;
  }

  Future handleUploadImage() async {
    ImagePicker picker = ImagePicker();
    await picker.pickImage(source: ImageSource.gallery).then((xFile) async {
      if (xFile != null) {
        setState(() {
          imageUrl = '';
          pickedImage = xFile;
        });
        List<int> data = await xFile.readAsBytes();
        String path = 'products';
        String? imgUrl = kIsWeb
            ? await FirebaseWebHelper.uploadFile(data, path)
            : await uploadImage(data, path);
        if (imgUrl != null) {
          setState(() {
            pickedImage = null;
            imageUrl = imgUrl;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width * (widget.isMobile ? 1 : 0.4),
        height: widget.isMobile ? MediaQuery.of(context).size.height : 800,
        padding: EdgeInsets.only(
          left: widget.isMobile ? 16 : 0,
          right: widget.isMobile ? 16 : 0,
          top: widget.isMobile ? 24 : 0,
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Column(
              children: [
                Row(
                  children: [
                    MySpacing.width(20),
                    if (widget.isEditing &&
                        imageUrl == "" &&
                        pickedImage == null)
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          if (widget.kanbanProject!.thumbnail != null)
                            Image.network(widget.kanbanProject!.thumbnail!,
                                width: 100),
                          if (imageUrl != "")
                            Positioned(
                                child: InkWell(
                              onTap: () {},
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                              ),
                            ))
                        ],
                      ),
                    widget.isEditing
                        ? MyButton.outlined(
                            onPressed: () async {
                              if (pickedImage != null) return;
                              await handleUploadImage();
                            },
                            borderColor: imageUrl != "" || pickedImage != null
                                ? Colors.transparent
                                : contentTheme.secondary,
                            padding: imageUrl != "" || pickedImage != null
                                ? MySpacing.zero
                                : EdgeInsets.all(0),
                            child: imageUrl != ""
                                ? Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Image.network(imageUrl, width: 60),
                                      Positioned(
                                          child: InkWell(
                                        onTap: () {
                                          deleteImage(imageUrl).then((value) {
                                            setState(() {
                                              pickedImage = null;
                                              imageUrl = "";
                                            });
                                          });
                                        },
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                        ),
                                      ))
                                    ],
                                  )
                                : pickedImage != null
                                    ? Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          kIsWeb
                                              ? Image.network(
                                                  pickedImage?.path ?? "",
                                                  width: 50,
                                                )
                                              : Image.file(
                                                  File(pickedImage?.path ?? ""),
                                                  width: 50,
                                                ),
                                          SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ],
                                      )
                                    : IconButton(
                                        onPressed: () async {
                                          if (pickedImage != null) return;
                                          await handleUploadImage();
                                        },
                                        icon: Icon(
                                          Icons.add_a_photo_rounded,
                                          color: contentTheme.secondary,
                                        ),
                                      ),
                          )
                        : MyButton.outlined(
                            onPressed: () async {
                              if (pickedImage != null) return;
                              await handleUploadImage();
                            },
                            borderColor: imageUrl != "" || pickedImage != null
                                ? Colors.transparent
                                : contentTheme.secondary,
                            padding: imageUrl != "" || pickedImage != null
                                ? MySpacing.zero
                                : MySpacing.xy(16, 16),
                            child: imageUrl != ""
                                ? Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Image.network(imageUrl, width: 60),
                                      Positioned(
                                          child: InkWell(
                                        onTap: () {
                                          deleteImage(imageUrl).then((value) {
                                            setState(() {
                                              pickedImage = null;
                                              imageUrl = "";
                                            });
                                          });
                                        },
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                        ),
                                      ))
                                    ],
                                  )
                                : pickedImage != null
                                    ? Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          kIsWeb
                                              ? Image.network(
                                                  pickedImage?.path ?? "",
                                                  width: 50,
                                                )
                                              : Image.file(
                                                  File(pickedImage?.path ?? ""),
                                                  width: 50,
                                                ),
                                          SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        ],
                                      )
                                    : MyText.labelMedium(
                                        'Select Thumbnail',
                                        fontWeight: 600,
                                      ),
                          )
                  ],
                ),
                MySpacing.height(16),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: MyText.bodyMedium(
                        "Project Name",
                        fontWeight: 600,
                        muted: true,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    TextFormField(
                      maxLines: 1,
                      onChanged: (value) {
                        setState(() {
                          title = value;
                        });
                      },
                      initialValue: widget.isEditing
                          ? widget.kanbanProject?.projectName ?? ''
                          : '',
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
                    if (isSubmitted && validateDescription(description) != null)
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
                MySpacing.height(16),
                Column(
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
                      initialValue: widget.isEditing
                          ? widget.kanbanProject?.description ?? ''
                          : '',
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
                    if (isSubmitted && validateDescription(description) != null)
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
                          child: widget.isEditing
                              ? MyText.bodyLarge(
                                  isSubmitting ? 'Updating' : 'Update',
                                  fontWeight: 600,
                                  color: theme.colorScheme.onError,
                                )
                              : MyText.bodyLarge(
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
