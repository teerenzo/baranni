import 'package:barrani/constants.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/models/kanban.dart';
import 'package:barrani/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appflowy_board/appflowy_board.dart';
import 'package:barrani/images.dart';
import 'package:intl/intl.dart';

final kanbanControllerProvider = Provider<KanBanController>((ref) {
  return KanBanController(
    kanbanProjectsProvider: ref.watch(kIsWeb
        ? FirebaseWebHelper.kanbanProjectsProvider
        : kanbanProjectsProvider),
    currentUsersStream: ref.watch(kIsWeb
        ? FirebaseWebHelper.allUsersStreamProvider
        : allUsersStreamProvider),
  );
});

class KanBanController extends ChangeNotifier {
  final AsyncValue<List<KanbanProject>> kanbanProjectsProvider;
  final AsyncValue<List<UserModal>> currentUsersStream;

  KanBanController(
      {required this.kanbanProjectsProvider, required this.currentUsersStream});

  final AppFlowyBoardController boardData = AppFlowyBoardController(
    onMoveGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
      debugPrint('Move item from $fromIndex to $toIndex');
    },
    onMoveGroupItem: (groupId, fromIndex, toIndex) {
      debugPrint('Move $groupId:$fromIndex to $groupId:$toIndex');
    },
    onMoveGroupItemToGroup: (fromGroupId, fromIndex, toGroupId, toIndex) async {
      print('Move $fromGroupId:$fromIndex to $toGroupId:$toIndex');

      // Identify the moved task

      // // Use orElse to handle not found

      if (allGroups.isEmpty) {
        // Handle the case where the source group is not found
        return;
      }

      AppFlowyGroupData<dynamic> fromGroup = allGroups.firstWhere(
        (group) => group.id == fromGroupId,
        orElse: () => null as AppFlowyGroupData<dynamic>,
      );

      allGroups.firstWhere((element) => element.id == fromGroupId).items;

      // Identify the moved task
      TextItem movedTask = fromGroup.items[fromIndex] as TextItem;
    },
  );

  late AppFlowyBoardScrollController boardController;

  void goToCreateKanbanTask() {
    NavigatorHelper.pushNamed('/features/add_kanban_task');
  }

  void initializeBoardData() {
    List<String> statuses = ["To Do", "In Progress", "Wait", "Done"];

    kanbanProjectsProvider.whenData((projects) {
      for (String? status in statuses) {
        if (status == null) {
          continue; // Skip null statuses
        }
        // Filter out projects based on the current status
        List<TextItem> statusItems = projects
            .where((project) => project.status == status)
            .map((project) {
          // Determine the appropriate photoUrl based on the assignedTo field
          List<String> userImages = [];

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
            boardData!.addGroup(statusGroup1);
            // allGroups.add(statusGroup1);
          } else if (status.contains('In Progress')) {
            final statusGroup2 = AppFlowyGroupData(
              id: 'In Progress',
              items: List<AppFlowyGroupItem>.from(statusItems),
              name: 'In Progress', // Use "Unknown" as a fallback,
            );
            boardData!.addGroup(statusGroup2);
            // allGroups.add(statusGroup2);
          } else if (status.contains('Wait')) {
            final statusGroup3 = AppFlowyGroupData(
              id: 'Wait',
              items: List<AppFlowyGroupItem>.from(statusItems),
              name: 'Wait', // Use "Unknown" as a fallback,
            );
            boardData!.addGroup(statusGroup3);
            // allGroups.add(statusGroup3);
          } else if (status.contains('Done')) {
            final statusGroup4 = AppFlowyGroupData(
              id: 'Done',
              items: List<AppFlowyGroupItem>.from(statusItems),
              name: 'Done', // Use "Unknown" as a fallback,
            );
            boardData!.addGroup(statusGroup4);
            // allGroups.add(statusGroup4);
          }
        }
      }
    }).when(
      data: (projects) {
        // Define the name based on status, even if no items are available
        // String name = statusToNameMap[statuses] ?? "Unknown";
        return projects;
      },
      loading: () => Center(
        child: CircularProgressIndicator(),
      ), // Handle loading state if necessary
      error: (error, stackTrace) => Center(
          child: Text(
              'Error: ${error.toString()}')), // Handle error state if necessary
    );
  }

  @override
  void dispose() {
    boardData.dispose();
    super.dispose();
  }
}

class TextItem extends AppFlowyGroupItem {
  final String? kanbanLevel;
  final Color? color;
  final String? date;
  final String? title;
  final String? name;
  final String? image;
  final String? jobTypeName;
  final List<String>? images;
  // final List<String> images,
  final String? kanbanProjectID; // This was already nullable
  // Add a groupId property
  String groupId; // This represents the group ID of the item

  TextItem({
    this.kanbanLevel,
    this.color,
    this.date,
    this.title,
    this.name,
    this.image,
    this.jobTypeName,
    this.images,
    this.kanbanProjectID,
    required this.groupId, // Pass the groupId when creating a TextItem
  });

  @override
  String get id => title ?? "placeholder";
  String? get projectId => kanbanProjectID;
}
