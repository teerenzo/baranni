import 'package:barrani/controller/my_controller.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/widgets/my_form_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TaskStatus {
  todo,
  doing,
  done,
}

class AddTaskController extends MyController {
  MyFormValidator basicValidator = MyFormValidator();
  TaskStatus selectedStatus = TaskStatus.todo;
  final CollectionReference tasks =
      FirebaseFirestore.instance.collection('projects');

  @override
  void onInit() {
    super.onInit();

    // You can add more fields here as per your requirements.
    basicValidator.addField(
      'kanbanLevel',
      label: "Kanban Level",
      required: true,
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'title',
      label: "Title",
      required: true,
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'date',
      label: "Date",
      required: true,
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'name',
      label: "Name",
      required: true,
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'image',
      label: "Image",
      required: true,
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'jobTypeName',
      label: "Job Type Name",
      required: true,
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'comment',
      label: "Comment",
      required: true,
      controller: TextEditingController(),
    );
  }

  // If you have any dropdown, you can manage its selection like this
  String selectedCategory = "Fashion";

  void onSelectedCategory(String category) {
    selectedCategory = category;
    update();
  }

  void onChangeStatus(TaskStatus? value) {
    selectedStatus = value ?? selectedStatus;
    update();
  }

  void onSelectedProjectName(String projectName) {
    selectedKanbanPriority = projectName;
    update();
  }

  void onSelectedPriority(String priority) {
    selectedKanbanPriority = priority;
    update();
  }

  // Future<void> saveTask() async {
  //   Task task = Task(
  //     projectName: basicValidator.getController('project_name')!.text,
  //     description: basicValidator.getController('description')!.text,
  //     startTime: DateTime.now().applied(TimeOfDay(
  //         hour: startTime.hour,
  //         minute: startTime.minute)), // Convert TimeOfDay to DateTime
  //     endTime: DateTime.now()
  //         .applied(TimeOfDay(hour: endTime.hour, minute: endTime.minute)),
  //     assignedTo: invites
  //         .map((user) => user.userId)
  //         .toList(), // Assuming invites is a list of users and each user has a userId
  //   );

  //   return tasks.add(task.toMap());
  // }
}
