import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:flutter/foundation.dart';

Appointment fromMap(Map<String, dynamic> p) {
  Timestamp sT = Timestamp.now();
  Timestamp eT = Timestamp.now();
  if (kIsWeb) {
    sT = p['startTime'];
    eT = p['endTime'];
  }
  return Appointment(
    id: p['id'],
    startTime: kIsWeb ? sT.toDate() : p['startTime'],
    endTime: kIsWeb ? eT.toDate() : p['endTime'],
    location: p['location'],
    color: Colors.green,
    subject: p['notes'] ?? "",
    notes: p['subject'],
    recurrenceId: p['recurrenceId'],
  );
}

Map<String, dynamic> toMap(Appointment p) {
  return {
    'startTime': p.startTime,
    'endTime': p.endTime,
    'location': p.location,
    'subject': p.notes,
    'notes': p.subject,
    'recurrenceId': p.recurrenceId,
  };
}
