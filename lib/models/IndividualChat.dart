class IndividualChat {
  String? _messages;
  DateTime? _createdAt;
  String? _createdBy;
  String? _receiverId;

  IndividualChat(
      {String? messages,
      DateTime? createdAt,
      String? createdBy,
      String? receiverId}) {
    if (messages != null) {
      this._messages = messages;
    }
    if (createdAt != null) {
      this._createdAt = createdAt;
    }
    if (createdBy != null) {
      this._createdBy = createdBy;
    }
    if (receiverId != null) {
      this._receiverId = receiverId;
    }
  }

  String? get messages => _messages;
  set messages(String? messages) => _messages = messages;
  DateTime? get createdAt => _createdAt;
  set createdAt(DateTime? createdAt) => _createdAt = createdAt;
  String? get createdBy => _createdBy;
  set createdBy(String? createdBy) => _createdBy = createdBy;
  String? get receiverId => _receiverId;
  set receiverId(String? receiverId) => _receiverId = receiverId;

  IndividualChat.fromJson(Map<String, dynamic> json) {
    _messages = json['messages'];

    _createdAt = json['createdAt'];
    _createdBy = json['createdBy'];
    _receiverId = json['receiverId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messages'] = this._messages;
    data['createdAt'] = this._createdAt;
    data['createdBy'] = this._createdBy;
    data['receiverId'] = this._receiverId;
    return data;
  }
}

class Messages {
  String? _message;
  String? _senderId;
  DateTime? _timestamp;
  String? _username;
  String? _receiverId;
  String? _chatId;
  String? _type;
  String? _profileImage;

  Messages(
      {String? message,
      String? senderId,
      DateTime? timestamp,
      String? username,
      String? receiverId,
      String? chatId,
      String? type,
      String? profileImage}) {
    if (message != null) {
      this._message = message;
    }
    if (senderId != null) {
      this._senderId = senderId;
    }
    if (timestamp != null) {
      this._timestamp = timestamp;
    }
    if (username != null) {
      this._username = username;
    }
    if (receiverId != null) {
      this._receiverId = receiverId;
    }
    if (chatId != null) {
      this._chatId = chatId;
    }
    if (type != null) {
      this._type = type;
    }
    if (profileImage != null) {
      this._profileImage = profileImage;
    }
  }

  String? get message => _message;
  set message(String? message) => _message = message;
  String? get senderId => _senderId;
  set senderId(String? senderId) => _senderId = senderId;
  DateTime? get timestamp => _timestamp;
  set timestamp(DateTime? timestamp) => _timestamp = timestamp;
  String? get username => _username;
  set username(String? username) => _username = username;
  String? get receiverId => _receiverId;
  set receiverId(String? receiverId) => _receiverId = receiverId;
  String? get chatId => _chatId;
  set chatId(String? chatId) => _chatId = chatId;
  String? get type => _type;
  set type(String? type) => _type = type;
  String? get profileImage => _profileImage;

  Messages.fromJson(Map<String, dynamic> json) {
    _message = json['message'];
    _senderId = json['senderId'];
    _timestamp = json['timestamp'];
    _username = json['username'];
    _receiverId = json['receiverId'];
    _chatId = json['chatId'];
    _type = json['type'];
    _profileImage = json['profileImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this._message;
    data['senderId'] = this._senderId;
    data['timestamp'] = this._timestamp;
    data['username'] = this._username;
    data['receiverId'] = this._receiverId;
    data['chatId'] = this._chatId;
    data['type'] = this._type;
    data['profileImage'] = this._profileImage;
    return data;
  }
}
