import 'package:appflowy_board/appflowy_board.dart';
import 'package:barrani/controller/my_controller.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class KanBanController extends MyController {
  late AppFlowyBoardController? boardData;

  late AppFlowyBoardScrollController boardController;

  void goToCreateKanbanTask() {
    NavigatorHelper.pushNamed('/features/add_kanban_task');
  }

  @override
  void onInit() {
    super.onInit();
    // Let's pre-fill the boardData with the default items first

    // Then, fetch the tasks from Firestore
    // _fetchTasks();
    boardData = AppFlowyBoardController(
      onMoveGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
        debugPrint('Move item from $fromIndex to $toIndex');
      },
      onMoveGroupItem: (groupId, fromIndex, toIndex) {
        debugPrint('Move $groupId:$fromIndex to $groupId:$toIndex');
      },
      onMoveGroupItemToGroup:
          (fromGroupId, fromIndex, toGroupId, toIndex) async {
        debugPrint('Move $fromGroupId:$fromIndex to $toGroupId:$toIndex');

        // Identify the moved task
        AppFlowyGroupData<dynamic> fromGroup = allGroups.firstWhere(
          (group) => group.id == fromGroupId,
          orElse: () => null as AppFlowyGroupData<dynamic>,
        );

        // Use orElse to handle not found

        if (fromGroup == null) {
          // Handle the case where the source group is not found
          return;
        }
        if (fromIndex < 0 || fromIndex >= fromGroup.items.length) {
          // Handle the case where fromIndex is out of bounds
          return;
        }

        // Identify the moved task
        TextItem movedTask = fromGroup.items[fromIndex] as TextItem;

        // if (fromIndex >= 0 && fromIndex < fromGroup.items.length) {
        //   // Determine new status based on the `toGroupId`
        //   String newStatus;
        //   switch (toGroupId) {
        //     case "To Do":
        //       newStatus = "To Do";
        //       break;
        //     case "In Progress":
        //       newStatus = "In Progress";
        //       break;
        //     case "Wait":
        //       newStatus = "Wait";
        //       break;
        //     case "Done":
        //       newStatus = "Done";
        //       break;
        //     default:
        //       newStatus = "Unknown";
        //   }
        //   // Here you can update your task with the newStatus
        //   // Example: updateTaskStatus(movedTask.id, newStatus);
        //   // Update the status in Firebase
        //   print('New status: $newStatus');

        //   // if (movedTask.kanbanProjectID != null &&
        //   //     movedTask.kanbanProjectID!.isNotEmpty) {
        //   //   await onUpdateKanbanProject(
        //   //           projectId: movedTask.kanbanProjectID, status: newStatus)
        //   //       .then((_) {})
        //   //       .catchError((error) {
        //   //     print('Failed to update project status: $error');
        //   //   });
        //   // } else {
        //   //   return;
        //   // }

        //   if (movedTask.kanbanProjectID != null &&
        //       movedTask.kanbanProjectID!.isNotEmpty) {
        //     try {
        //       await onUpdateKanbanProject(
        //           projectId: movedTask.kanbanProjectID, status: newStatus);
        //       print('Update successful.');
        //     } catch (error) {
        //       print('Failed to update project status: $error');
        //     }
        //   } else {
        //     print('Kanban project ID is missing.');
        //   }
        // } else {
        //   return;
        // }
        // Determine new status based on the `toGroupId`
        String newStatus;
        switch (toGroupId) {
          case "To Do":
            newStatus = "To Do";
            break;
          case "In Progress":
            newStatus = "In Progress";
            break;
          case "Wait":
            newStatus = "Wait";
            break;
          case "Done":
            newStatus = "Done";
            break;
          default:
            newStatus = "Unknown";
        }
        // Update the item's group ID to the new group
        movedTask.groupId = toGroupId;

        // Remove the item from the source group
        final removedItem = fromGroup.items.removeAt(fromIndex);

        // Find the destination group by ID
        AppFlowyGroupData<dynamic> toGroup = allGroups.firstWhere(
          (group) => group.id == toGroupId,
          orElse: () => null as AppFlowyGroupData<dynamic>,
        );

        if (toGroup == null) {
          // Handle the case where the destination group is not found
          return;
        }

        // Insert the item at the new index in the destination group
        toGroup.items.insert(toIndex, removedItem);
// Now, print the debug information
        // Here you can update your task with the newStatus in Firestore
        if (movedTask.kanbanProjectID != null &&
            movedTask.kanbanProjectID!.isNotEmpty) {
          try {
            kIsWeb
                ? await FirebaseWebHelper.onUpdateKanbanProject(
                    projectId: movedTask.kanbanProjectID, status: newStatus)
                : await onUpdateKanbanProject(
                    projectId: movedTask.kanbanProjectID, status: newStatus);
          } catch (error) {
            return;
          }
        } else {
          return;
        }
      },
    );
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
