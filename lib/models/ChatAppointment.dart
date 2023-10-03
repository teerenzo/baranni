class ChatAppointment {
  List<Attendees>? _attendees;
  DateTime? _endTime;
  String? _location;
  DateTime? _startTime;
  String? _subject;

  ChatAppointment(
      {List<Attendees>? attendees,
      DateTime? endTime,
      String? location,
      DateTime? startTime,
      String? subject}) {
    if (attendees != null) {
      this._attendees = attendees;
    }
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

  List<Attendees>? get attendees => _attendees;
  set attendees(List<Attendees>? attendees) => _attendees = attendees;
  DateTime? get endTime => _endTime;
  set endTime(DateTime? endTime) => _endTime = endTime;
  String? get location => _location;
  set location(String? location) => _location = location;
  DateTime? get startTime => _startTime;
  set startTime(DateTime? startTime) => _startTime = startTime;
  String? get subject => _subject;
  set subject(String? subject) => _subject = subject;

  ChatAppointment.fromJson(Map<String, dynamic> json) {
    if (json['attendees'] != null) {
      _attendees = <Attendees>[];
      json['attendees'].forEach((v) {
        _attendees!.add(new Attendees.fromJson(v));
      });
    }
    _endTime = json['endTime'];
    _location = json['location'];
    _startTime = json['startTime'];
    _subject = json['subject'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this._attendees != null) {
      data['attendees'] = this._attendees!.map((v) => v.toJson()).toList();
    }
    data['endTime'] = this._endTime;
    data['location'] = this._location;
    data['startTime'] = this._startTime;
    data['subject'] = this._subject;
    return data;
  }
}

class Attendees {
  String? _email;
  String? names;
  String? _role;
  String? _userId;
  String? _status;
  bool? _isCreator;
  String? profile_url;

  Attendees(
      {String? email,
      String? names,
      String? role,
      String? userId,
      String? status,
      bool? isCreator,
      String? profile_url}) {
    if (email != null) {
      this._email = email;
    }
    if (names != null) {
      this.names = names;
    }

    if (role != null) {
      this._role = role;
    }
    if (userId != null) {
      this._userId = userId;
    }
    if (status != null) {
      this._status = status;
    }

    if (isCreator != null) {
      this._isCreator = isCreator;
    }
    if (profile_url != null) {
      this.profile_url = profile_url;
    }
  }

  String? get status => _status;
  set status(String? status) => _status = status;
  String? get email => _email;
  set email(String? email) => _email = email;
  String? get _names => names;
  set _names(String? names) => names = names;
  String? get role => _role;
  set role(String? role) => _role = role;
  String? get userId => _userId;
  set userId(String? userId) => _userId = userId;
  bool? get isCreator => _isCreator;
  set isCreator(bool? isCreator) => _isCreator = isCreator;

  String? get profileUrl => profile_url;
  set profileUrl(String? profile_url) => profile_url = profile_url;

  Attendees.fromJson(Map<String, dynamic> json) {
    _email = json['email'];
    names = json['names'];
    _role = json['role'];
    _userId = json['userId'];
    _status = json['status'];
    _isCreator = json['isCreator'];
    profile_url = json['profile_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email'] = this._email;
    data['names'] = this.names;
    data['role'] = this._role;
    data['userId'] = this._userId;
    data['status'] = this._status;
    data['isCreator'] = this._isCreator;
    data['profile_url'] = this.profile_url;
    return data;
  }
}
