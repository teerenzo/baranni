import 'package:cloud_firestore/cloud_firestore.dart';

class KanbanTask {
  final String kanbanLevel;
  final String jobTypeName;
  final String? userId;
  final String projectName;
  final String description;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> assignedTo;
  final String? id; // optional field for document ID
  final String? projectId;

  KanbanTask({
    required this.kanbanLevel,
    required this.jobTypeName,
    required this.userId,
    required this.projectName,
    required this.description,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.assignedTo,
    this.id,
    this.projectId,
  });

  static DateTime _convertToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    throw ArgumentError('Expected Timestamp or DateTime, but got $timestamp');
  }

  factory KanbanTask.fromMap(Map<String, dynamic> map) {
    return KanbanTask(
      kanbanLevel: map['kanbanLevel'],
      jobTypeName: map['jobTypeName'],
      userId: map['userId'],
      projectName: map['taskName'],
      description: map['description'],
      status: map['status'],
      startTime: KanbanTask._convertToDateTime(map['startTime']),
      endTime: KanbanTask._convertToDateTime(map['endTime']),
      assignedTo: List<String>.from(map['assignedTo']),
      id: map['id'],
      projectId: map['projectId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kanbanLevel': kanbanLevel,
      'jobTypeName': jobTypeName,
      'userId': userId,
      'taskName': projectName,
      'description': description,
      'status': status,
      'startTime': startTime,
      'endTime': endTime,
      'assignedTo': assignedTo,
      'projectId': projectId,
      // 'id': id,  // This is optional, you might not want to include the document ID when writing back to Firestore
    };
  }

  @override
  toString() {
    return 'KanbanTask: $id $projectName';
  }
}
