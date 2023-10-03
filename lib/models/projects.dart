import 'package:cloud_firestore/cloud_firestore.dart';

class Projects {
  final String projectId;
  final String projectTypeName;
  final String? userId;
  final String projectName;
  final String description;
  final String status;
  final DateTime startTime;
  final DateTime endTime;
  // final List<String> assignedTo;
  // final String? id; // optional field for document ID

  Projects({
    required this.projectId,
    required this.projectTypeName,
    required this.userId,
    required this.projectName,
    required this.description,
    required this.status,
    required this.startTime,
    required this.endTime,
    // required this.assignedTo,
    // this.id,
  });

  static DateTime _convertToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    throw ArgumentError('Expected Timestamp or DateTime, but got $timestamp');
  }

  factory Projects.fromMap(Map<String, dynamic> map) {
    return Projects(
      projectId: map['project_id'],
      projectTypeName: map['jobTypeName'],
      userId: map['userId'],
      projectName: map['projectName'],
      description: map['description'],
      status: map['status'],
      startTime: Projects._convertToDateTime(map['startTime']),
      endTime: Projects._convertToDateTime(map['endTime']),
      // assignedTo: List<String>.from(map['assignedTo']),
      // id: map['id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'project_id': projectId,
      'jobTypeName': projectTypeName,
      'userId': userId,
      'projectName': projectName,
      'description': description,
      'status': status,
      'startTime': startTime,
      'endTime': endTime,
      // 'assignedTo': assignedTo,
      // 'id': id,  // This is optional, you might not want to include the document ID when writing back to Firestore
    };
  }

  @override
  toString() {
    return 'Projects: $projectName';
  }
}
