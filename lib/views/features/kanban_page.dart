import 'package:appflowy_board/appflowy_board.dart';
import 'package:barrani/constants.dart';
import 'package:barrani/controller/features/kanban_controller.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/extensions/string.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/theme/app_style.dart';
import 'package:barrani/helpers/theme/app_theme.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb_item.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_list_extension.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/responsive.dart';
import 'package:barrani/images.dart';
import 'package:barrani/models/user.dart';
import 'package:barrani/views/layouts/layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class KanBanPage extends ConsumerStatefulWidget {
  static const routeName = '/kanban';
  const KanBanPage({Key? key}) : super(key: key);

  @override
  ConsumerState<KanBanPage> createState() => _KanBanPageState();
}

class _KanBanPageState extends ConsumerState<KanBanPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late KanBanController controller;
  late ScrollController _controller;
  List<String> statuses = ["To Do", "In Progress", "Wait", "Done"];
  // Define a map that maps each status to its corresponding name
  Map<String, String> statusToNameMap = {
    "To Do": "To Do",
    "In Progress": "In Progress",
    "Wait": "Wait",
    "Done": "Done",
  };

  @override
  void initState() {
    super.initState();
    if (mounted) {
      controller = Get.put(KanBanController());
      controller.boardController = AppFlowyBoardScrollController();
      _controller = ScrollController();
      controller.boardData!.clear();
      allGroups.clear();
      userImages.clear();
      filteredUsers.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    // var currentUsersStream = ref.watch(allUsersStreamProvider);
    var currentUsersStream = ref.watch(kIsWeb
        ? FirebaseWebHelper.allUsersStreamProvider
        : allUsersStreamProvider);
    final kanbanProjects = ref.watch(kIsWeb
        ? FirebaseWebHelper.kanbanProjectsProvider
        : kanbanProjectsProvider);

    // Define the static names for each group
    Map<String, String> groupNames = {
      "To Do": "To Do",
      "In Progress": "In Progress",
      "Wait": "Wait",
      "Done": "Done",
    };
    // Create empty groups for each status
    Map<String, AppFlowyGroupData> groups = {};

    kanbanProjects.when(
      data: (projects) {
        // Define the name based on status, even if no items are available
        String name = statusToNameMap[statuses] ?? "Unknown";
        for (String? status in statuses) {
          if (status == null) {
            continue; // Skip null statuses
          }
          // Filter out projects based on the current status
          List<TextItem> statusItems = projects
              .where((project) => project.status == status)
              .map((project) {
            // Determine the appropriate photoUrl based on the assignedTo field
            // List<String> userImages = [];

            currentUsersStream.whenData((currentUsers) {
              // Filter out the current user
              filteredUsers = currentUsers
                  .where((element) => element.userId != userData?.userId)
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

            String? formattedStartTime = project.startTime != null
                ? DateFormat('jm').format(project.startTime)
                : null;
            String? formattedEndTime = project.endTime != null
                ? DateFormat('jm').format(project.endTime)
                : null;

            String? timeRange =
                formattedStartTime != null && formattedEndTime != null
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
              groupId: status, // Set the groupId to the current status
            );
          }).toList();

          // Create a single AppFlowyGroupData object for the current status
          if (statusItems.isNotEmpty) {
            if (status.contains('To Do')) {
              final statusGroup1 = AppFlowyGroupData(
                id: 'To Do',
                items: List<AppFlowyGroupItem>.from(statusItems),
                name: 'To Do', // Use "Unknown" as a fallback,
              );
              controller.boardData!.addGroup(statusGroup1);
              allGroups.add(statusGroup1);
            } else if (status.contains('In Progress')) {
              final statusGroup2 = AppFlowyGroupData(
                id: 'In Progress',
                items: List<AppFlowyGroupItem>.from(statusItems),
                name: 'In Progress', // Use "Unknown" as a fallback,
              );
              controller.boardData!.addGroup(statusGroup2);
              allGroups.add(statusGroup2);
            } else if (status.contains('Wait')) {
              final statusGroup3 = AppFlowyGroupData(
                id: 'Wait',
                items: List<AppFlowyGroupItem>.from(statusItems),
                name: 'Wait', // Use "Unknown" as a fallback,
              );
              controller.boardData!.addGroup(statusGroup3);
              allGroups.add(statusGroup3);
            } else if (status.contains('Done')) {
              final statusGroup4 = AppFlowyGroupData(
                id: 'Done',
                items: List<AppFlowyGroupItem>.from(statusItems),
                name: 'Done', // Use "Unknown" as a fallback,
              );
              controller.boardData!.addGroup(statusGroup4);
              allGroups.add(statusGroup4);
            }
          }
        }
      },
      loading: () => Center(
        child: CircularProgressIndicator(),
      ), // Handle loading state if necessary
      error: (error, stackTrace) => Center(
          child: Text(
              'Error: ${error.toString()}')), // Handle error state if necessary
    );

    return Stack(
      children: [
        Layout(
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
                            onPressed: controller.goToCreateKanbanTask,
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
                    child: PrimaryScrollController(
                      controller: ScrollController(),
                      child: AppFlowyBoard(
                        config: AppFlowyBoardConfig(
                          stretchGroupHeight: false,
                          groupBackgroundColor:
                              contentTheme.primary.withAlpha(20),
                        ),
                        controller: controller.boardData!,
                        cardBuilder: (context, group, groupItem) {
                          // int index = statuses.indexOf(group.id);
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
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        if (!kIsWeb) // Only show this FAB if it's not on web
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: controller.goToCreateKanbanTask,
              backgroundColor: contentTheme.primary,
              child: Icon(
                LucideIcons.plus,
                color: Color(0xffffffff),
              ),
            ),
          ),
      ],
    );
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
                        children: item.images!
                            .mapIndexed((index, imageUrl) => Positioned(
                                  left: (18 + (20 * index)).toDouble(),
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
                                ))
                            .toList()),
                  ),
                ),
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
                MyContainer.none(
                  paddingAll: 8,
                  borderRadiusAll: 5,
                  child: PopupMenuButton(
                    offset: const Offset(-150, 15),
                    position: PopupMenuPosition.under,
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                          padding: MySpacing.xy(16, 8),
                          height: 10,
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.plusCircle,
                                size: 20,
                              ),
                              MySpacing.width(8),
                              MyText.bodySmall("Add People"),
                            ],
                          )),
                      PopupMenuItem(
                          padding: MySpacing.xy(16, 8),
                          height: 10,
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.edit,
                                size: 20,
                              ),
                              MySpacing.width(8),
                              MyText.bodySmall("Edit"),
                            ],
                          )),
                      PopupMenuItem(
                          padding: MySpacing.xy(16, 8),
                          height: 10,
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.trash,
                                size: 20,
                              ),
                              MySpacing.width(8),
                              MyText.bodySmall("Delete"),
                            ],
                          )),
                      PopupMenuItem(
                          padding: MySpacing.xy(16, 8),
                          height: 10,
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.logOut,
                                size: 20,
                              ),
                              MySpacing.width(8),
                              MyText.bodySmall("Leave"),
                            ],
                          )),
                    ],
                    child: const Icon(
                      LucideIcons.moreVertical,
                      size: 18,
                    ),
                  ),
                ),
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
