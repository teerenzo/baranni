import 'package:cloud_firestore/cloud_firestore.dart';

class KanbanProject {
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

  KanbanProject({
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
  });

  static DateTime _convertToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    throw ArgumentError('Expected Timestamp or DateTime, but got $timestamp');
  }

  factory KanbanProject.fromMap(Map<String, dynamic> map) {
    return KanbanProject(
      kanbanLevel: map['kanbanLevel'],
      jobTypeName: map['jobTypeName'],
      userId: map['userId'],
      projectName: map['projectName'],
      description: map['description'],
      status: map['status'],
      startTime: KanbanProject._convertToDateTime(map['startTime']),
      endTime: KanbanProject._convertToDateTime(map['endTime']),
      assignedTo: List<String>.from(map['assignedTo']),
      id: map['id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kanbanLevel': kanbanLevel,
      'jobTypeName': jobTypeName,
      'userId': userId,
      'projectName': projectName,
      'description': description,
      'status': status,
      'startTime': startTime,
      'endTime': endTime,
      'assignedTo': assignedTo,
      // 'id': id,  // This is optional, you might not want to include the document ID when writing back to Firestore
    };
  }

  @override
  toString() {
    return 'KanbanProject: $id $projectName';
  }
}
