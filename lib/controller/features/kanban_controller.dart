import 'package:barrani/constants.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/models/kanbanProject.dart';
import 'package:barrani/models/kanbanTask.dart';
import 'package:barrani/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:appflowy_board/appflowy_board.dart';
import 'package:barrani/images.dart';
import 'package:intl/intl.dart';

final kanbanControllerProvider = Provider<KanBanController>((ref) {
  return KanBanController(
    kanbanProjectsProvider: ref.watch(
        kIsWeb ? FirebaseWebHelper.kanbanTasksProvider : kanbanTasksProvider),
    currentUsersStream: ref.watch(kIsWeb
        ? FirebaseWebHelper.allUsersStreamProvider
        : allUsersStreamProvider),
  );
});

class KanBanController extends ChangeNotifier {
  final AsyncValue<List<KanbanTask>> kanbanProjectsProvider;
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
      // // Identify the moved task
      AppFlowyGroupData<dynamic> fromGroup = allGroups.firstWhere(
        (group) => group.id == toGroupId,
      );

      TextItem movedTask = fromGroup.items[toIndex] as TextItem;

      if (movedTask.kanbanProjectID != null &&
          movedTask.kanbanProjectID!.isNotEmpty) {
        try {
          kIsWeb
              ? FirebaseWebHelper.onUpdateKanbanProject(
                  projectId: movedTask.kanbanProjectID, status: toGroupId)
              : onUpdateKanbanProject(
                  projectId: movedTask.kanbanProjectID, status: toGroupId);
        } catch (error) {
          print(error);
          return;
        }
      } else {
        return;
      }
    },
  );

  late AppFlowyBoardScrollController boardController;

  void goToCreateKanbanTask() {
    NavigatorHelper.pushNamed('/features/add_kanban_task');
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
