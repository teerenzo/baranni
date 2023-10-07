import 'package:cloud_firestore/cloud_firestore.dart';

class KanbanProject {
  final String? userId;
  final String projectName;
  final String? thumbnail;
  final String description;
  final DateTime startDate;
  final String? id; // optional field for document ID

  KanbanProject({
    required this.userId,
    required this.projectName,
    required this.description,
    required this.startDate,
    this.id,
    this.thumbnail,
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
      userId: map['userId'],
      projectName: map['projectName'],
      description: map['description'],
      startDate: KanbanProject._convertToDateTime(map['startTime']),
      id: map['id'],
      thumbnail: map['thumbnail'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'projectName': projectName,
      'description': description,
      'createdDate': startDate,
      'thumbnail': thumbnail,
    };
  }

  @override
  toString() {
    return 'KanbanProject: $id $projectName';
  }
}
