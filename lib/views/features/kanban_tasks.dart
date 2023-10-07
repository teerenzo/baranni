import 'dart:math';

import 'package:appflowy_board/appflowy_board.dart';
import 'package:barrani/constants.dart';
import 'package:barrani/controller/features/kanban_controller.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/extensions/extensions.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/storage/local_storage.dart';
import 'package:barrani/helpers/theme/app_style.dart';
import 'package:barrani/helpers/theme/theme_provider.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/models/kanbanProject.dart';
import 'package:barrani/models/kanbanTask.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:barrani/helpers/theme/app_theme.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb_item.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/responsive.dart';
import 'package:barrani/views/layouts/layout.dart';

class KanBanTaskPage extends ConsumerStatefulWidget {
  static const routeName = '/kanban/tasks';

  const KanBanTaskPage({Key? key}) : super(key: key);

  @override
  ConsumerState<KanBanTaskPage> createState() => _KanBanTaskPageState();
}

class _KanBanTaskPageState extends ConsumerState<KanBanTaskPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late ScrollController _controller;

  late AppFlowyBoardScrollController boardController;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    allGroups.clear();
    userImages.clear();
    filteredUsers.clear();
  }

  @override
  Widget build(BuildContext context) {
    final projectId = LocalStorage.getProjectId();

    final kanbanTasKProvider = ref.watch(
        kIsWeb ? FirebaseWebHelper.kanbanTasksProvider : kanbanTasksProvider);
    final currentUsersStream = ref.watch(kIsWeb
        ? FirebaseWebHelper.allUsersStreamProvider
        : allUsersStreamProvider);
    ref.watch(themesProvider);

    return Scaffold(
        floatingActionButton: !kIsWeb
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/kanban/task/add');
                },
                child: Icon(Icons.add),
              )
            : null,
        body: Layout(
          child: Consumer(
            // init: controller,
            builder: (context, watch, child) {
              final controller = ref.watch(kanbanControllerProvider);
              controller.boardController = AppFlowyBoardScrollController();

              return Column(
                children: [
                  Padding(
                    padding: MySpacing.x(flexSpacing),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText.titleMedium(
                          "KanBan",
                          fontSize: 18,
                          fontWeight: 600,
                        ),
                        MyBreadcrumb(
                          children: [
                            MyBreadcrumbItem(name: 'Apps'),
                            MyBreadcrumbItem(name: 'KanBan', active: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  MySpacing.height(flexSpacing),
                  Padding(
                    padding: MySpacing.x(flexSpacing),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (kIsWeb)
                          MyButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                '/kanban/task/add',
                              );
                            },
                            elevation: 0,
                            padding: MySpacing.xy(20, 16),
                            backgroundColor: contentTheme.primary,
                            borderRadiusAll: AppStyle.buttonRadius.medium,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  LucideIcons.plus,
                                  color: Color(0xffffffff),
                                ),
                                MySpacing.width(8),
                                MyText.labelMedium(
                                  'create_task'.tr().capitalizeWords,
                                  color: contentTheme.onPrimary,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  MySpacing.height(flexSpacing),
                  Padding(
                      padding: MySpacing.x(flexSpacing / 2),
                      child: kanbanTasKProvider.whenData(
                        (data) {
                          controller.boardData.clear();
                          allGroups.clear();
                          List<KanbanTask> projects = data
                              .where(
                                  (element) => element.projectId == projectId)
                              .toList();

                          List<TextItem> statusItemsToDo = projects
                              .where((project) => project.status == 'To Do')
                              .toList()
                              .map((project) {
                            // Determine the appropriate photoUrl based on the assignedTo field
                            List<String> userImages = [];

                            currentUsersStream.whenData(
                              (currentUsers) {
                                // Filter out the current user
                                filteredUsers = currentUsers
                                    .where((element) =>
                                        element.userId != userData?.userId)
                                    .toList();

                                // Loop through all current users and check if their ID exists in project.assignedTo
                                for (var user in filteredUsers) {
                                  if (project.assignedTo
                                      .contains(user.userId)) {
                                    if (user.photoUrl.isNotEmpty) {
                                      userImages.add(user.photoUrl);
                                    }
                                    userImages.add(profileImageUrl);
                                  }
                                }
                              },
                            );

                            // Determine color based on kanbanPriority
                            Color priorityColor;
                            switch (project.kanbanLevel) {
                              case "High":
                                priorityColor = Colors.red.shade400;
                                break;
                              case "Medium":
                                priorityColor = Colors.brown;
                                break;
                              case "Low":
                              default:
                                priorityColor = Colors.green.shade400;
                                break;
                            }

                            String? formattedStartTime =
                                project.startTime != null
                                    ? DateFormat('jm').format(project.startTime)
                                    : null;
                            String? formattedEndTime = project.endTime != null
                                ? DateFormat('jm').format(project.endTime)
                                : null;

                            String? timeRange = formattedStartTime != null &&
                                    formattedEndTime != null
                                ? 'From: $formattedStartTime - To: $formattedEndTime'
                                : null;

                            return TextItem(
                              kanbanLevel: project.kanbanLevel,
                              color: priorityColor,
                              date: timeRange,
                              title: project.projectName,
                              name: userData!.names,
                              image: userData!.photoUrl,
                              jobTypeName: project.jobTypeName,
                              images: userImages,
                              kanbanProjectID: project.id,
                              groupId:
                                  'To Do', // Set the groupId to the current status
                            );
                          }).toList();

                          List<TextItem> statusItemsInProgress = projects
                              .where((project) =>
                                  project.status == 'In Progress' &&
                                  project.projectId == projectId)
                              .map((project) {
                            // Determine the appropriate photoUrl based on the assignedTo field
                            List<String> userImages = [];

                            currentUsersStream.whenData(
                              (currentUsers) {
                                // Filter out the current user
                                filteredUsers = currentUsers
                                    .where((element) =>
                                        element.userId != userData?.userId)
                                    .toList();

                                // Loop through all current users and check if their ID exists in project.assignedTo
                                for (var user in filteredUsers) {
                                  if (project.assignedTo
                                      .contains(user.userId)) {
                                    if (user.photoUrl.isNotEmpty) {
                                      userImages.add(user.photoUrl);
                                    }
                                    userImages.add(profileImageUrl);
                                  }
                                }
                              },
                            );

                            // Determine color based on kanbanPriority
                            Color priorityColor;
                            switch (project.kanbanLevel) {
                              case "High":
                                priorityColor = Colors.red.shade400;
                                break;
                              case "Medium":
                                priorityColor = Colors.brown;
                                break;
                              case "Low":
                              default:
                                priorityColor = Colors.green.shade400;
                                break;
                            }

                            String? formattedStartTime =
                                project.startTime != null
                                    ? DateFormat('jm').format(project.startTime)
                                    : null;
                            String? formattedEndTime = project.endTime != null
                                ? DateFormat('jm').format(project.endTime)
                                : null;

                            String? timeRange = formattedStartTime != null &&
                                    formattedEndTime != null
                                ? 'From: $formattedStartTime - To: $formattedEndTime'
                                : null;

                            return TextItem(
                              kanbanLevel: project.kanbanLevel,
                              color: priorityColor,
                              date: timeRange,
                              title: project.projectName,
                              name: userData!.names,
                              image: userData!.photoUrl,
                              jobTypeName: project.jobTypeName,
                              images: userImages,
                              kanbanProjectID: project.id,
                              groupId:
                                  'In Progress', // Set the groupId to the current status
                            );
                          }).toList();

                          List<TextItem> statusItemsWait = projects
                              .where((project) =>
                                  project.status == 'Wait' &&
                                  project.projectId == projectId)
                              .toList()
                              .map((project) {
                            // Determine the appropriate photoUrl based on the assignedTo field
                            List<String> userImages = [];

                            currentUsersStream.whenData((currentUsers) {
                              // Filter out the current user
                              filteredUsers = currentUsers
                                  .where((element) =>
                                      element.userId != userData?.userId)
                                  .toList();

                              // Loop through all current users and check if their ID exists in project.assignedTo
                              for (var user in filteredUsers) {
                                if (project.assignedTo.contains(user.userId)) {
                                  if (user.photoUrl.isNotEmpty) {
                                    userImages.add(user.photoUrl);
                                  }
                                  userImages.add(profileImageUrl);
                                }
                              }
                            });

                            // Determine color based on kanbanPriority
                            Color priorityColor;
                            switch (project.kanbanLevel) {
                              case "High":
                                priorityColor = Colors.red.shade400;
                                break;
                              case "Medium":
                                priorityColor = Colors.brown;
                                break;
                              case "Low":
                              default:
                                priorityColor = Colors.green.shade400;
                                break;
                            }

                            String? formattedStartTime =
                                project.startTime != null
                                    ? DateFormat('jm').format(project.startTime)
                                    : null;
                            String? formattedEndTime = project.endTime != null
                                ? DateFormat('jm').format(project.endTime)
                                : null;

                            String? timeRange = formattedStartTime != null &&
                                    formattedEndTime != null
                                ? 'From: $formattedStartTime - To: $formattedEndTime'
                                : null;

                            return TextItem(
                              kanbanLevel: project.kanbanLevel,
                              color: priorityColor,
                              date: timeRange,
                              title: project.projectName,
                              name: userData!.names,
                              image: userData!.photoUrl,
                              jobTypeName: project.jobTypeName,
                              images: userImages,
                              kanbanProjectID: project.id,
                              groupId:
                                  'Wait', // Set the groupId to the current status
                            );
                          }).toList();

                          List<TextItem> statusItemsDone = projects
                              .where((project) =>
                                  project.status == 'Done' &&
                                  project.projectId == projectId)
                              .toList()
                              .map((project) {
                            // Determine the appropriate photoUrl based on the assignedTo field
                            List<String> userImages = [];

                            currentUsersStream.whenData((currentUsers) {
                              // Filter out the current user
                              filteredUsers = currentUsers
                                  .where((element) =>
                                      element.userId != userData?.userId)
                                  .toList();

                              // Loop through all current users and check if their ID exists in project.assignedTo
                              for (var user in filteredUsers) {
                                if (project.assignedTo.contains(user.userId)) {
                                  if (user.photoUrl.isNotEmpty) {
                                    userImages.add(user.photoUrl);
                                  }
                                  userImages.add(profileImageUrl);
                                }
                              }
                            });

                            // Determine color based on kanbanPriority
                            Color priorityColor;
                            switch (project.kanbanLevel) {
                              case "High":
                                priorityColor = Colors.red.shade400;
                                break;
                              case "Medium":
                                priorityColor = Colors.brown;
                                break;
                              case "Low":
                              default:
                                priorityColor = Colors.green.shade400;
                                break;
                            }

                            String? formattedStartTime =
                                project.startTime != null
                                    ? DateFormat('jm').format(project.startTime)
                                    : null;
                            String? formattedEndTime = project.endTime != null
                                ? DateFormat('jm').format(project.endTime)
                                : null;

                            String? timeRange = formattedStartTime != null &&
                                    formattedEndTime != null
                                ? 'From: $formattedStartTime - To: $formattedEndTime'
                                : null;

                            return TextItem(
                              kanbanLevel: project.kanbanLevel,
                              color: priorityColor,
                              date: timeRange,
                              title: project.projectName,
                              name: userData!.names,
                              image: userData!.photoUrl,
                              jobTypeName: project.jobTypeName,
                              images: userImages,
                              kanbanProjectID: project.id,
                              groupId:
                                  'Done', // Set the groupId to the current status
                            );
                          }).toList();

                          final todo = AppFlowyGroupData(
                            id: 'To Do',
                            items:
                                List<AppFlowyGroupItem>.from(statusItemsToDo),
                            name: 'To Do', // Use "Unknown" as a fallback,
                          );

                          final inProgress = AppFlowyGroupData(
                            id: 'In Progress',
                            items: List<AppFlowyGroupItem>.from(
                                statusItemsInProgress),
                            name: 'In Progress', // Use "Unknown" as a fallback,
                          );

                          final wait = AppFlowyGroupData(
                            id: 'Wait',
                            items:
                                List<AppFlowyGroupItem>.from(statusItemsWait),
                            name: 'Wait', // Use "Unknown" as a fallback,
                          );

                          final done = AppFlowyGroupData(
                            id: 'Done',
                            items:
                                List<AppFlowyGroupItem>.from(statusItemsDone),
                            name: 'Done', // Use "Unknown" as a fallback,
                          );
                          controller.boardData.addGroup(todo);
                          controller.boardData.addGroup(inProgress);
                          controller.boardData.addGroup(wait);

                          controller.boardData.addGroup(done);

                          allGroups.addAll(controller.boardData.groupDatas);

                          return PrimaryScrollController(
                            controller: ScrollController(),
                            child: AppFlowyBoard(
                              config: AppFlowyBoardConfig(
                                stretchGroupHeight: false,
                                groupBackgroundColor:
                                    contentTheme.primary.withAlpha(20),
                              ),
                              controller: controller.boardData,
                              cardBuilder: (context, group, groupItem) {
                                return AppFlowyGroupCard(
                                  key: ValueKey(group.id),
                                  decoration: BoxDecoration(
                                      color: theme.colorScheme.background),
                                  child: buildCard(groupItem),
                                );
                              },
                              boardScrollController: controller.boardController,
                              footerBuilder: (context, columnData) {
                                return MySpacing.height(16);
                              },
                              headerBuilder: (context, columnData) {
                                return SizedBox(
                                  height: 40,
                                  child: ListView.builder(
                                    controller: _controller,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return AppFlowyGroupHeader(
                                        title: MyText.bodyMedium(
                                          columnData.headerData.groupName,
                                          fontSize: 16,
                                          fontWeight: 600,
                                          muted: true,
                                        ),
                                        margin: MySpacing.x(16),
                                        height: 40,
                                      );
                                    },
                                  ),
                                );
                              },
                              groupConstraints: const BoxConstraints.tightFor(
                                width: 400,
                              ),
                            ),
                          );
                        },
                      ).when(data: (data) {
                        return data;
                      }, error: (error, s) {
                        return Text(error.toString());
                      }, loading: () {
                        return Center(child: CircularProgressIndicator());
                      })),
                ],
              );
            },
          ),
        ));
  }

  Widget buildCard(AppFlowyGroupItem item) {
    if (item is TextItem) {
      return Padding(
        padding: MySpacing.xy(12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyContainer(
                  color: item.color,
                  borderRadiusAll: 4,
                  padding: MySpacing.xy(8, 4),
                  child: MyText(
                    item.kanbanLevel ?? '',
                    fontSize: 12,
                    color: contentTheme.onPrimary,
                  ),
                ),
                MyText.bodyMedium(item.date ?? '', muted: true)
              ],
            ),
            MySpacing.height(12),
            MyText.bodyMedium(
              item.title ?? '',
            ),
            MySpacing.height(12),
            Row(
              children: [
                const Icon(
                  LucideIcons.luggage,
                  size: 16,
                ),
                MySpacing.width(8),
                MyText.bodyMedium(item.jobTypeName ?? '', muted: true),
                MySpacing.width(16),
                // const Icon(
                //   LucideIcons.messageSquare,
                //   size: 20,
                // ),
                MySpacing.width(8),
                // MyText.bodyMedium("${item.images} comments", muted: true),
                SizedBox(
                  width: 161,
                  height: 30,
                  child: SizedBox(
                    width: 161,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: item.images?.asMap().entries.map((entry) {
                            final index = entry.key;
                            final imageUrl = entry.value;
                            final leftPosition = 18 + (20 * index).toDouble();
                            if (imageUrl == '') return Container();
                            return Positioned(
                              left: leftPosition,
                              child: MyContainer.rounded(
                                paddingAll: 2,
                                child: MyContainer.rounded(
                                  bordered: true,
                                  paddingAll: 0,
                                  child: Image.network(
                                    imageUrl,
                                    height: 28,
                                    width: 28,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          }).toList() ??
                          [],
                    ),
                  ),
                )
              ],
            ),
            MySpacing.height(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    MyContainer.rounded(
                      paddingAll: 0,
                      height: 32,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Image.network(item.image ?? ''),
                    ),
                    MySpacing.width(8),
                    MyText.bodyMedium(
                      item.name ?? '',
                    ),
                  ],
                ),
                // MyContainer.none(
                //   paddingAll: 8,
                //   borderRadiusAll: 5,
                //   child: PopupMenuButton(
                //     offset: const Offset(-150, 15),
                //     position: PopupMenuPosition.under,
                //     itemBuilder: (BuildContext context) => [
                //       PopupMenuItem(
                //           padding: MySpacing.xy(16, 8),
                //           height: 10,
                //           child: Row(
                //             children: [
                //               const Icon(
                //                 LucideIcons.plusCircle,
                //                 size: 20,
                //               ),
                //               MySpacing.width(8),
                //               MyText.bodySmall("Add People"),
                //             ],
                //           )),
                //       PopupMenuItem(
                //           padding: MySpacing.xy(16, 8),
                //           height: 10,
                //           child: Row(
                //             children: [
                //               const Icon(
                //                 LucideIcons.edit,
                //                 size: 20,
                //               ),
                //               MySpacing.width(8),
                //               MyText.bodySmall("Edit"),
                //             ],
                //           )),
                //       PopupMenuItem(
                //           padding: MySpacing.xy(16, 8),
                //           height: 10,
                //           child: Row(
                //             children: [
                //               const Icon(
                //                 LucideIcons.trash,
                //                 size: 20,
                //               ),
                //               MySpacing.width(8),
                //               MyText.bodySmall("Delete"),
                //             ],
                //           )),
                //       PopupMenuItem(
                //           padding: MySpacing.xy(16, 8),
                //           height: 10,
                //           child: Row(
                //             children: [
                //               const Icon(
                //                 LucideIcons.logOut,
                //                 size: 20,
                //               ),
                //               MySpacing.width(8),
                //               MyText.bodySmall("Leave"),
                //             ],
                //           )),
                //     ],
                //     child: const Icon(
                //       LucideIcons.moreVertical,
                //       size: 18,
                //     ),
                //   ),
                // ),
              ],
            )
          ],
        ),
      );
    }

    if (item is RichTextItem) {
      return RichTextCard(item: item);
    }

    throw UnimplementedError();
  }
}

class RichTextCard extends StatefulWidget {
  final RichTextItem item;

  const RichTextCard({
    required this.item,
    Key? key,
  }) : super(key: key);

  @override
  State<RichTextCard> createState() => _RichTextCardState();
}

class _RichTextCardState extends State<RichTextCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}

class RichTextItem extends AppFlowyGroupItem {
  final String title;
  final String subtitle;

  RichTextItem({required this.title, required this.subtitle});

  @override
  String get id => title;
}
