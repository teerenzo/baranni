class GroupChat {
  final String firstName, message, sendUser, groubId;
  final String? type;
  final DateTime sendAt;
  bool fromMe = true;

  GroupChat(
    this.firstName,
    this.message,
    this.sendAt,
    this.sendUser,
    this.groubId,
    this.fromMe,
    this.type,
  );
}
