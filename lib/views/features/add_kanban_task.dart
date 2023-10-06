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
import 'package:barrani/helpers/theme/app_style.dart';
import 'package:barrani/helpers/theme/app_theme.dart';
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
  late AddTaskController controller;
  static const orange = Color(0xFFFE9A75);
  static const dark = Color(0xFF333A47);
  static const double leftPadding = 50;
  late DateTime startDate = DateTime.now();
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

  Future<void> submitToFirestore() async {
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
            kanbanLevel: selectedKanbanPriority,
            jobTypeName: _jobTypeName.text,
            projectId: projectId)
        : onCreateKanbanTask(
            userId: userData?.userId,
            projectName: _projectName.text,
            description: _description.text,
            startTimeDate: startDate.applied(startTime),
            endTimeDate: startDate.applied(endTime),
            inviteeIds: inviteeIds,
            kanbanLevel: selectedKanbanPriority,
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
    controller = Get.put(AddTaskController());
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
    // var currentUsersStream = ref.watch(allUsersStreamProvider);
    var currentUsersStream = ref.watch(kIsWeb
        ? FirebaseWebHelper.allUsersStreamProvider
        : allUsersStreamProvider);
    final KanbanProject project =
        ModalRoute.of(context)!.settings.arguments as KanbanProject;

    setState(() {
      projectId = project.id!;
    });

    return Layout(
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return Column(
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
                          name: Trans('add_project').tr.capitalizeWords,
                          active: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              MySpacing.height(flexSpacing * 1),
              Padding(
                padding: MySpacing.x(flexSpacing / 1),
                child: MyFlex(
                  children: [
                    MyFlexItem(
                      sizes: "lg-8",
                      child: MyCard(
                        shadow: MyShadow(elevation: 0.5),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
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
                                    sizes: "lg-6",
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText.labelMedium(
                                          Trans("Project Name")
                                              .tr
                                              .capitalizeWords,
                                        ),
                                        MySpacing.height(8),
                                        TextFormField(
                                          keyboardType: TextInputType.name,
                                          initialValue: project.projectName,
                                          readOnly: true,
                                          decoration: InputDecoration(
                                            hintText: "eg: kanban",
                                            hintStyle: MyTextStyle.bodySmall(
                                                xMuted: true),
                                            border: outlineInputBorder,
                                            enabledBorder: outlineInputBorder,
                                            focusedBorder: focusedInputBorder,
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
                                    decoration: InputDecoration(
                                      hintText: "eg: login",
                                      hintStyle:
                                          MyTextStyle.bodySmall(xMuted: true),
                                      border: outlineInputBorder,
                                      enabledBorder: outlineInputBorder,
                                      focusedBorder: focusedInputBorder,
                                      contentPadding: MySpacing.all(16),
                                      isCollapsed: true,
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                    ),
                                  ),

                                  MySpacing.height(25),
                                  MyText.labelMedium(
                                    Trans("Description").tr,
                                  ),
                                  MySpacing.height(8),
                                  TextFormField(
                                    // validator: controller.basicValidator
                                    //     .getValidation('description'),
                                    controller: _description,
                                    keyboardType: TextInputType.multiline,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      hintText: "kanban is.....",
                                      hintStyle:
                                          MyTextStyle.bodySmall(xMuted: true),
                                      border: outlineInputBorder,
                                      enabledBorder: outlineInputBorder,
                                      focusedBorder: focusedInputBorder,
                                      contentPadding: MySpacing.all(16),
                                      isCollapsed: true,
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.never,
                                    ),
                                  ),
                                  MySpacing.height(20),
                                  MyFlexItem(
                                    sizes: "lg-6",
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText.labelMedium(
                                          Trans("Project Type")
                                              .tr
                                              .capitalizeWords,
                                        ),
                                        MySpacing.height(8),
                                        TextFormField(
                                          controller: _jobTypeName,
                                          keyboardType: TextInputType.name,
                                          decoration: InputDecoration(
                                            hintText: "eg: Bugfix",
                                            hintStyle: MyTextStyle.bodySmall(
                                                xMuted: true),
                                            border: outlineInputBorder,
                                            enabledBorder: outlineInputBorder,
                                            focusedBorder: focusedInputBorder,
                                            contentPadding: MySpacing.all(16),
                                            isCollapsed: true,
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.never,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  MySpacing.height(20),
                                  MyFlexItem(
                                      sizes: 'lg-6 md-12',
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MyText.labelMedium(
                                            Trans("Project Priority").tr,
                                          ),
                                          MySpacing.height(8),
                                          PopupMenuButton(
                                            onSelected:
                                                controller.onSelectedPriority,
                                            itemBuilder:
                                                (BuildContext context) {
                                              return [
                                                "Medium",
                                                "High",
                                                "Low",
                                              ].map((behavior) {
                                                return PopupMenuItem(
                                                  value: behavior,
                                                  height: 32,
                                                  child: MyText.bodySmall(
                                                    behavior.toString(),
                                                    color: theme.colorScheme
                                                        .onBackground,
                                                    fontWeight: 600,
                                                  ),
                                                );
                                              }).toList();
                                            },
                                            color: theme.cardTheme.color,
                                            child: MyContainer.bordered(
                                              padding: MySpacing.xy(12, 8),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  MyText.labelMedium(
                                                    selectedKanbanPriority,
                                                    color: theme.colorScheme
                                                        .onBackground,
                                                  ),
                                                  Icon(
                                                    Icons.expand_more_outlined,
                                                    size: 22,
                                                    color: theme.colorScheme
                                                        .onBackground,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                  MySpacing.height(20),
                                  // MyFlex(
                                  //   contentPadding: false,
                                  //   children: [
                                  //     MyFlexItem(
                                  //       sizes: "lg-6",
                                  //       child: Column(
                                  //         crossAxisAlignment:
                                  //             CrossAxisAlignment.start,
                                  //         children: [
                                  //           MyText.bodyMedium(
                                  //             "Start Time",
                                  //             fontWeight: 600,
                                  //             muted: true,
                                  //           ),
                                  //           MySpacing.height(8),
                                  //           MyContainer.bordered(
                                  //             paddingAll: 12,
                                  //             onTap: () async {
                                  //               if (isSubmitting) {
                                  //                 return;
                                  //               }
                                  //               TimeOfDay? t = await pickTime(
                                  //                   context, startTime);
                                  //               if (t != null) {
                                  //                 setState(() {
                                  //                   startTime = t;
                                  //                 });
                                  //                 filterUser();
                                  //               }
                                  //             },
                                  //             borderColor:
                                  //                 theme.colorScheme.secondary,
                                  //             child: Row(
                                  //               mainAxisAlignment:
                                  //                   MainAxisAlignment.start,
                                  //               crossAxisAlignment:
                                  //                   CrossAxisAlignment.start,
                                  //               children: <Widget>[
                                  //                 Icon(
                                  //                   LucideIcons.calendar,
                                  //                   color: theme
                                  //                       .colorScheme.secondary,
                                  //                   size: 16,
                                  //                 ),
                                  //                 MySpacing.width(10),
                                  //                 MyText.bodyMedium(
                                  //                   timeHourFormatter.format(
                                  //                     startDate
                                  //                         .applied(startTime),
                                  //                   ),
                                  //                   fontWeight: 600,
                                  //                   color: theme
                                  //                       .colorScheme.secondary,
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //           ),
                                  //           if (isAppointmentExist(startDate
                                  //                   .applied(startTime)) &&
                                  //               isSubmitted)
                                  //             MyText.bodyMedium(
                                  //               'Selected Start Time is occupied',
                                  //               fontWeight: 600,
                                  //               muted: true,
                                  //               color: kAlertColor,
                                  //               textAlign: TextAlign.start,
                                  //             ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //     MyFlexItem(
                                  //       sizes: "lg-6",
                                  //       child: Column(
                                  //         crossAxisAlignment:
                                  //             CrossAxisAlignment.start,
                                  //         children: [
                                  //           MyText.bodyMedium(
                                  //             "End Time",
                                  //             fontWeight: 600,
                                  //             muted: true,
                                  //           ),
                                  //           MySpacing.height(8),
                                  //           MyContainer.bordered(
                                  //             paddingAll: 12,
                                  //             onTap: () async {
                                  //               if (isSubmitting) {
                                  //                 return;
                                  //               }
                                  //               TimeOfDay? t = await pickTime(
                                  //                   context, endTime);
                                  //               if (t != null) {
                                  //                 setState(() {
                                  //                   endTime = t;
                                  //                 });
                                  //                 filterUser();
                                  //               }
                                  //             },
                                  //             borderColor:
                                  //                 theme.colorScheme.secondary,
                                  //             child: Row(
                                  //               mainAxisAlignment:
                                  //                   MainAxisAlignment.start,
                                  //               crossAxisAlignment:
                                  //                   CrossAxisAlignment.start,
                                  //               children: <Widget>[
                                  //                 Icon(
                                  //                   LucideIcons.calendar,
                                  //                   color: theme
                                  //                       .colorScheme.secondary,
                                  //                   size: 16,
                                  //                 ),
                                  //                 MySpacing.width(10),
                                  //                 MyText.bodyMedium(
                                  //                   timeHourFormatter.format(
                                  //                     startDate
                                  //                         .applied(endTime),
                                  //                   ),
                                  //                   fontWeight: 600,
                                  //                   color: theme
                                  //                       .colorScheme.secondary,
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //           ),
                                  //           if (isAppointmentExist(startDate
                                  //                   .applied(endTime)) &&
                                  //               isSubmitted)
                                  //             MyText.bodyMedium(
                                  //               'Selected End Time is occupied',
                                  //               fontWeight: 600,
                                  //               muted: true,
                                  //               color: kAlertColor,
                                  //               textAlign: TextAlign.start,
                                  //             ),
                                  //         ],
                                  //       ),
                                  //     ),
                                  //   ],
                                  // ),
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
                                              paddingAll: 12,
                                              onTap: () async {
                                                if (isSubmitting) {
                                                  return;
                                                }
                                                if (!kIsWeb) {
                                                  bottomTimePicker(
                                                      context,
                                                      startDate.applied(
                                                          startTime), (date) {
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
                                              borderColor:
                                                  theme.colorScheme.secondary,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Icon(
                                                    LucideIcons.calendar,
                                                    color: theme
                                                        .colorScheme.secondary,
                                                    size: 16,
                                                  ),
                                                  MySpacing.width(10),
                                                  MyText.bodyMedium(
                                                    timeHourFormatter.format(
                                                      startDate
                                                          .applied(startTime),
                                                    ),
                                                    fontWeight: 600,
                                                    color: theme
                                                        .colorScheme.secondary,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isAppointmentExist(startDate
                                                    .applied(startTime)) &&
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
                                              muted: true,
                                            ),
                                            MySpacing.height(8),
                                            MyContainer.bordered(
                                              paddingAll: 12,
                                              onTap: () async {
                                                if (isSubmitting) {
                                                  return;
                                                }
                                                if (!kIsWeb) {
                                                  bottomTimePicker(
                                                      context,
                                                      startDate.applied(
                                                          endTime), (date) {
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
                                              borderColor:
                                                  theme.colorScheme.secondary,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Icon(
                                                    LucideIcons.calendar,
                                                    color: theme
                                                        .colorScheme.secondary,
                                                    size: 16,
                                                  ),
                                                  MySpacing.width(10),
                                                  MyText.bodyMedium(
                                                    timeHourFormatter.format(
                                                      startDate
                                                          .applied(endTime),
                                                    ),
                                                    fontWeight: 600,
                                                    color: theme
                                                        .colorScheme.secondary,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isAppointmentExist(startDate
                                                    .applied(endTime)) &&
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
                                                  element.userId !=
                                                  userData?.userId)
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
                                                child:
                                                    CircularProgressIndicator(),
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
                                      MyButton.text(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        padding: MySpacing.xy(20, 16),
                                        splashColor: contentTheme.secondary
                                            .withOpacity(0.1),
                                        child: MyText.bodySmall(
                                          Trans('cancel').tr,
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
                                        borderRadiusAll:
                                            AppStyle.buttonRadius.medium,
                                        child: Row(
                                          children: [
                                            loading
                                                ? SizedBox(
                                                    height: 14,
                                                    width: 14,
                                                    child:
                                                        CircularProgressIndicator(
                                                      color: theme.colorScheme
                                                          .onPrimary,
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
          );
        },
      ),
    );
  }
}
