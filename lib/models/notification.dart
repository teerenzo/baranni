import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModal {
  String id;
  String title;
  String body;
  String userId;
  bool isRead;
  DateTime createdAt;

  NotificationModal(
    this.id,
    this.title,
    this.body,
    this.userId,
    this.isRead,
    this.createdAt,
  );

  factory NotificationModal.fromJson(Map<String, dynamic> json) {
    DateTime? d;
    if (json['createdAt'] is DateTime) {
      d = json['createdAt'];
    } else {
      Timestamp p = json['createdAt'];
      d = p.toDate();
    }
    return NotificationModal(
      json['id'],
      json['title'],
      json['body'],
      json['userId'],
      json['isRead'],
      d!,
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
      'isRead': isRead,
      'createdAt': createdAt,
    };
  }
}
