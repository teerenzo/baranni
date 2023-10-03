class ChatInvitation {
  String? _appointmentId;
  AppointmentInfo? _appointmentInfo;
  String? _receiverId;
  String? _senderId;
  String? _status;

  ChatInvitation(
      {String? appointmentId,
      AppointmentInfo? appointmentInfo,
      String? receiverId,
      String? senderId,
      String? status}) {
    if (appointmentId != null) {
      this._appointmentId = appointmentId;
    }
    if (appointmentInfo != null) {
      this._appointmentInfo = appointmentInfo;
    }
    if (receiverId != null) {
      this._receiverId = receiverId;
    }
    if (senderId != null) {
      this._senderId = senderId;
    }
    if (status != null) {
      this._status = status;
    }
  }

  String? get appointmentId => _appointmentId;
  set appointmentId(String? appointmentId) => _appointmentId = appointmentId;
  AppointmentInfo? get appointmentInfo => _appointmentInfo;
  set appointmentInfo(AppointmentInfo? appointmentInfo) =>
      _appointmentInfo = appointmentInfo;
  String? get receiverId => _receiverId;
  set receiverId(String? receiverId) => _receiverId = receiverId;
  String? get senderId => _senderId;
  set senderId(String? senderId) => _senderId = senderId;
  String? get status => _status;
  set status(String? status) => _status = status;

  ChatInvitation.fromJson(Map<String, dynamic> json) {
    _appointmentId = json['appointment_id'];
    _appointmentInfo = json['appointment_info'] != null
        ? new AppointmentInfo.fromJson(json['appointment_info'])
        : null;
    _receiverId = json['receiver_id'];
    _senderId = json['sender_id'];
    _status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['appointment_id'] = this._appointmentId;
    if (this._appointmentInfo != null) {
      data['appointment_info'] = this._appointmentInfo!.toJson();
    }
    data['receiver_id'] = this._receiverId;
    data['sender_id'] = this._senderId;
    data['status'] = this._status;
    return data;
  }
}

class AppointmentInfo {
  DateTime? _endTime;
  String? _location;
  DateTime? _startTime;
  String? _subject;

  AppointmentInfo(
      {DateTime? endTime,
      String? location,
      DateTime? startTime,
      String? subject}) {
    if (endTime != null) {
      this._endTime = endTime;
    }
    if (location != null) {
      this._location = location;
    }
    if (startTime != null) {
      this._startTime = startTime;
    }
    if (subject != null) {
      this._subject = subject;
    }
  }

  DateTime? get endTime => _endTime;
  set endTime(DateTime? endTime) => _endTime = endTime;
  String? get location => _location;
  set location(String? location) => _location = location;
  DateTime? get startTime => _startTime;
  set startTime(DateTime? startTime) => _startTime = startTime;
  String? get subject => _subject;
  set subject(String? subject) => _subject = subject;

  AppointmentInfo.fromJson(Map<String, dynamic> json) {
    _endTime = json['endTime'];
    _location = json['location'];
    _startTime = json['startTime'];
    _subject = json['subject'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['endTime'] = this._endTime;
    data['location'] = this._location;
    data['startTime'] = this._startTime;
    data['subject'] = this._subject;
    return data;
  }
}
