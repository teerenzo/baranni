import 'package:barrani/app_constant.dart';
import 'package:barrani/constants.dart';
import 'package:barrani/controller/features/kanban_add_task_controller.dart';
import 'package:barrani/global_functions.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/extensions/date_time_extention.dart';
import 'package:barrani/helpers/extensions/string.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/storage/local_storage.dart';
import 'package:barrani/helpers/theme/app_style.dart';
import 'package:barrani/helpers/theme/theme_provider.dart';

import 'package:barrani/helpers/utils/my_shadow.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb_item.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_card.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_flex.dart';
import 'package:barrani/helpers/widgets/my_flex_item.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/my_text_style.dart';
import 'package:barrani/helpers/widgets/responsive.dart';
import 'package:barrani/models/kanbanProject.dart';
import 'package:barrani/models/user.dart';
import 'package:barrani/views/layouts/layout.dart';
import 'package:barrani/widgets/appointment_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AddTask extends ConsumerStatefulWidget {
  static const routeName = '/kanban/task/add';
  const AddTask({Key? key}) : super(key: key);

  @override
  ConsumerState<AddTask> createState() => _AddTaskState();
}

class _AddTaskState extends ConsumerState<AddTask>
    with SingleTickerProviderStateMixin, UIMixin {
  static const orange = Color(0xFFFE9A75);
  static const dark = Color(0xFF333A47);
  static const double leftPadding = 50;
  late DateTime startDate = DateTime.now();
  String selectedKanbanTaskPriority = "Medium";
  List<UserModal> invites = [];
  // Get the values from the form
  GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController _projectName = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _jobTypeName = TextEditingController();

  bool loading = false;

  late TimeOfDay startTime;
  late TimeOfDay endTime;
  bool isSubmitting = false;
  bool isSubmitted = false;
  String projectId = "";
  String titleError = "";

  void filterUser() {
    List<UserModal> filteredUsers = invites
        .where((element) =>
            !isUserInvited(startDate.applied(startTime), element.userId) &&
            !isUserInvited(startDate.applied(endTime), element.userId) &&
            element.userId != userData?.userId)
        .toList();
    setState(() {
      invites = filteredUsers;
    });
  }

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

  String? validateTitle(String value) {
    if (value.isEmpty) {
      setState(() {
        titleError = 'Task name is required';
      });
      return titleError;
    }

    if (value.isNotEmpty) {
      setState(() {
        titleError = '';
      });
      return null;
    }

    return null;
  }

  Future<void> submitToFirestore() async {
    if (validateTitle(_projectName.text) != null) {
      return;
    }

    setState(() {
      loading = true;
    });

    // Extracting invitee user IDs. Assuming UserModal has a userId field.
    List<String> inviteeIds = invites.map((user) => user.userId).toList();

    kIsWeb
        ? FirebaseWebHelper.onCreateKanbanTask(
            userId: userData?.userId,
            projectName: _projectName.text,
            description: _description.text,
            startTimeDate: startDate.applied(startTime),
            endTimeDate: startDate.applied(endTime),
            inviteeIds: inviteeIds,
            kanbanLevel: selectedKanbanTaskPriority,
            jobTypeName: _jobTypeName.text,
            projectId: projectId)
        : onCreateKanbanTask(
            userId: userData?.userId,
            projectName: _projectName.text,
            description: _description.text,
            startTimeDate: startDate.applied(startTime),
            endTimeDate: startDate.applied(endTime),
            inviteeIds: inviteeIds,
            kanbanLevel: selectedKanbanTaskPriority,
            jobTypeName: _jobTypeName.text,
            projectId: projectId,
          );

    setState(() {
      loading = false;
    });

    // Navigator.popAndPushNamed(context, '/kanban');
    showMessage(
      context: context,
      message: 'Project created sussessfully!',
      backgroundColor: contentTheme.success,
    );
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    startTime = TimeOfDay(
      hour: startDate.hour,
      minute: startDate.minute,
    );
    endTime = TimeOfDay(
      hour: startDate.hour + 2,
      minute: startDate.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themesProvider);
    // var currentUsersStream = ref.watch(allUsersStreamProvider);
    var currentUsersStream = ref.watch(kIsWeb
        ? FirebaseWebHelper.allUsersStreamProvider
        : allUsersStreamProvider);

    setState(() {
      projectId = LocalStorage.getProjectId()!;
    });

    return Layout(
        child: Column(
      children: [
        Padding(
          padding: MySpacing.x(flexSpacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.titleMedium(
                Trans("Add Task").tr.capitalizeWords,
                fontSize: 18,
                fontWeight: 600,
              ),
              MyBreadcrumb(
                children: [
                  MyBreadcrumbItem(name: Trans('kanban').tr),
                  MyBreadcrumbItem(
                    name: Trans('add_task').tr.capitalizeWords,
                    active: true,
                  ),
                ],
              ),
            ],
          ),
        ),
        MySpacing.height(flexSpacing * 1),
        Padding(
          padding: MySpacing.x(flexSpacing),
          child: MyFlex(
            children: [
              MyFlexItem(
                sizes: "lg-8 sm-12",
                child: MyCard(
                  shadow: MyShadow(elevation: 0.5),
                  child: Padding(
                    padding: !kIsWeb
                        ? const EdgeInsets.only(
                            top: 8.0, right: 0.0, left: 0.0, bottom: 8.0)
                        : const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              LucideIcons.server,
                              size: 16,
                            ),
                            MySpacing.width(12),
                            MyText.titleMedium(
                              Trans("general").tr,
                              fontWeight: 600,
                            ),
                          ],
                        ),
                        MySpacing.height(flexSpacing),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyFlexItem(
                              sizes: "lg-6 sm-12",
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText.labelMedium(
                                    Trans("Project Name").tr.capitalizeWords,
                                  ),
                                  MySpacing.height(8),
                                  TextFormField(
                                    keyboardType: TextInputType.name,
                                    initialValue:
                                        LocalStorage.getProjectName(projectId),
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      hintText: "eg: kanban",
                                      hintStyle:
                                          MyTextStyle.bodySmall(xMuted: true),
                                      border: outlineInputBorder,
                                      contentPadding: MySpacing.all(16),
                                      isCollapsed: true,
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            MySpacing.height(25),
                            MyText.labelMedium(
                              Trans("Task Name").tr.capitalizeWords,
                            ),
                            MySpacing.height(8),
                            TextFormField(
                              controller: _projectName,
                              keyboardType: TextInputType.name,
                              onChanged: (value) {
                                validateTitle(value);
                              },
                              decoration: InputDecoration(
                                hintText: "eg: login",
                                hintStyle: MyTextStyle.bodySmall(xMuted: true),
                                border: outlineInputBorder,
                                contentPadding: MySpacing.all(16),
                                isCollapsed: true,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                              ),
                            ),
                            if (titleError.isNotEmpty)
                              MyText.bodyMedium(
                                titleError,
                                fontWeight: 600,
                                muted: true,
                                color: kAlertColor,
                                textAlign: TextAlign.start,
                              ),
                            MySpacing.height(25),
                            MyText.labelMedium(
                              Trans("Description").tr,
                            ),
                            MySpacing.height(8),
                            TextFormField(
                              controller: _description,
                              keyboardType: TextInputType.multiline,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: "login is.....",
                                hintStyle: MyTextStyle.bodySmall(xMuted: true),
                                border: outlineInputBorder,
                                contentPadding: MySpacing.all(16),
                                isCollapsed: true,
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.never,
                              ),
                            ),
                            MySpacing.height(20),
                            MyFlexItem(
                              sizes: "lg-6 sm-12",
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText.labelMedium(
                                    Trans("Task Type").tr.capitalizeWords,
                                  ),
                                  MySpacing.height(8),
                                  TextFormField(
                                    controller: _jobTypeName,
                                    keyboardType: TextInputType.name,
                                    decoration: InputDecoration(
                                        hintText: "eg: Bugfix",
                                        hintStyle:
                                            MyTextStyle.bodySmall(xMuted: true),
                                        border: outlineInputBorder,
                                        contentPadding: MySpacing.all(16),
                                        isCollapsed: true,
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.never),
                                  ),
                                ],
                              ),
                            ),
                            MySpacing.height(20),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: MyText.labelMedium(
                                Trans("Priority").tr.capitalizeWords,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: Container(
                                          height: 200,
                                          width: 200,
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ListTile(
                                                title: Text(
                                                  'Medium',
                                                  style: TextStyle(
                                                      color: theme.colorScheme
                                                          .onBackground),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    selectedKanbanTaskPriority =
                                                        'Medium';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'High',
                                                  style: TextStyle(
                                                      color: theme.colorScheme
                                                          .onBackground),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    selectedKanbanTaskPriority =
                                                        'High';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                              ListTile(
                                                title: Text(
                                                  'Low',
                                                  style: TextStyle(
                                                      color: theme.colorScheme
                                                          .onBackground),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    selectedKanbanTaskPriority =
                                                        'Low';
                                                  });
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    });
                              },
                              child: MyFlexItem(
                                  sizes: 'lg-6 md-12',
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                        strokeAlign: 0,
                                        color: theme.colorScheme.onBackground
                                            .withOpacity(0.3),
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 15.0),
                                          child: MyText.labelMedium(
                                            Trans(selectedKanbanTaskPriority)
                                                .tr,
                                          ),
                                        ),
                                        MySpacing.height(8),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child:
                                              Icon(Icons.expand_more_outlined),
                                        )
                                      ],
                                    ),
                                  )),
                            ),
                            MySpacing.height(20),
                            MyFlex(
                              contentPadding: false,
                              children: [
                                MyFlexItem(
                                  sizes: "lg-6",
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText.bodyMedium(
                                        "Start Time",
                                        fontWeight: 600,
                                        muted: true,
                                      ),
                                      MySpacing.height(8),
                                      MyContainer.bordered(
                                        // border: Border.all(
                                        //   color: theme.colorScheme.primary,
                                        // ),
                                        paddingAll: 12,
                                        onTap: () async {
                                          if (isSubmitting) {
                                            return;
                                          }
                                          if (!kIsWeb) {
                                            bottomTimePicker(context,
                                                startDate.applied(startTime),
                                                (date) {
                                              setState(() {
                                                startTime = TimeOfDay(
                                                    hour: date.hour,
                                                    minute: date.minute);
                                              });

                                              filterUser();
                                            });
                                          } else {
                                            TimeOfDay? t = await pickTime(
                                                context, startTime);
                                            if (t != null) {
                                              setState(() {
                                                startTime = t;
                                              });
                                              filterUser();
                                            }
                                          }
                                        },
                                        border: Border.all(
                                          width: 1,
                                          strokeAlign: 0,
                                          color: theme.colorScheme.onBackground
                                              .withOpacity(0.3),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              LucideIcons.calendar,
                                              color:
                                                  theme.colorScheme.secondary,
                                              size: 16,
                                            ),
                                            MySpacing.width(10),
                                            MyText.bodyMedium(
                                              timeHourFormatter.format(
                                                startDate.applied(startTime),
                                              ),
                                              fontWeight: 600,
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isAppointmentExist(
                                              startDate.applied(startTime)) &&
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText.bodyMedium(
                                        "End Time",
                                        fontWeight: 600,
                                        muted: false,
                                      ),
                                      MySpacing.height(8),
                                      MyContainer.bordered(
                                        paddingAll: 12,
                                        onTap: () async {
                                          if (isSubmitting) {
                                            return;
                                          }
                                          if (!kIsWeb) {
                                            bottomTimePicker(context,
                                                startDate.applied(endTime),
                                                (date) {
                                              setState(() {
                                                endTime = TimeOfDay(
                                                    hour: date.hour,
                                                    minute: date.minute);
                                              });
                                            });
                                          } else {
                                            TimeOfDay? t = await pickTime(
                                                context, endTime);
                                            if (t != null) {
                                              setState(() {
                                                endTime = t;
                                              });
                                              filterUser();
                                            }
                                          }
                                        },
                                        border: Border.all(
                                          width: 1,
                                          strokeAlign: 0,
                                          color: theme.colorScheme.onBackground
                                              .withOpacity(0.3),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(
                                              LucideIcons.calendar,
                                              color:
                                                  theme.colorScheme.secondary,
                                              size: 16,
                                            ),
                                            MySpacing.width(10),
                                            MyText.bodyMedium(
                                              timeHourFormatter.format(
                                                startDate.applied(endTime),
                                              ),
                                              fontWeight: 600,
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isAppointmentExist(
                                              startDate.applied(endTime)) &&
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
                            Container(
                              alignment: Alignment.centerLeft,
                              child: MyText.bodyMedium(
                                "Assigned To",
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
                                        .where((element) =>
                                            element.userId != userData?.userId)
                                        .map((e) => InviteAvatar(
                                              user: e,
                                              isInvited: isInvited(e),
                                              isMobile: true,
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
                            MySpacing.height(20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                MyButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  elevation: 0,
                                  padding: MySpacing.xy(20, 16),
                                  backgroundColor: contentTheme.secondary,
                                  borderRadiusAll: AppStyle.buttonRadius.medium,
                                  child: Row(
                                    children: [
                                      Icon(
                                        LucideIcons.x,
                                        size: 16,
                                        color: contentTheme.light,
                                      ),
                                      MySpacing.width(8),
                                      MyText.bodySmall(
                                        'Cancel',
                                        color: contentTheme.onSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                                MySpacing.width(12),
                                MyButton(
                                  onPressed: () async {
                                    try {
                                      await submitToFirestore();
                                      // Optionally show a success message to the user
                                      // replace with your UI logic
                                    } catch (e) {
                                      // Handle any errors

                                      // replace with your UI logic
                                      return;
                                    }
                                  },
                                  elevation: 0,
                                  padding: MySpacing.xy(20, 16),
                                  backgroundColor: contentTheme.primary,
                                  borderRadiusAll: AppStyle.buttonRadius.medium,
                                  child: Row(
                                    children: [
                                      loading
                                          ? SizedBox(
                                              height: 14,
                                              width: 14,
                                              child: CircularProgressIndicator(
                                                color:
                                                    theme.colorScheme.onPrimary,
                                                strokeWidth: 1.2,
                                              ),
                                            )
                                          : Container(),
                                      if (loading) MySpacing.width(16),
                                      MyText.bodySmall(
                                        Trans('save').tr,
                                        color: contentTheme.onPrimary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }
}
