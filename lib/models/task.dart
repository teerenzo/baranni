class Task {
  final String? projectName;
  final String? description;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String>? assignedTo; // List of user IDs assigned to the task

  Task({
    this.projectName,
    this.description,
    this.startTime,
    this.endTime,
    this.assignedTo,
  });

  Map<String, dynamic> toMap() {
    return {
      'projectName': projectName,
      'description': description,
      'startTime': startTime,
      'endTime': endTime,
      'assignedTo': assignedTo,
    };
  }
}
