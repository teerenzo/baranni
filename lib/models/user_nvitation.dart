class UserInvitation {
  String id;
  String invitation;
  String name;
  int type;
  bool isUsed;
  DateTime createdDate;

  UserInvitation({
    required this.id,
    required this.invitation,
    required this.name,
    required this.type,
    required this.isUsed,
    required this.createdDate,
  });

  //Get
  factory UserInvitation.fromJson(Map<String, dynamic> json) {
    return UserInvitation(
      id: json['id'],
      invitation: json['invitation'],
      name: json['name'],
      type: json['type'],
      isUsed: json['isUsed'],
      createdDate: json['createdDate'],
    );
  }

  //Set
  Map<String, dynamic> toMap() {
    return {
      'invitation': invitation,
      'name': name,
      'type': type,
      'isUsed': isUsed,
      'createdDate': createdDate,
    };
  }

  @override
  String toString() {
    return 'Invitation: $invitation - $name ($isUsed)';
  }
}
