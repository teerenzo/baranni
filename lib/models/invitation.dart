class Invitation {
  final String id;
  final String appointmentId;
  final String senderId;
  final String receiverId;
  final String status;

  Invitation({
    required this.id,
    required this.appointmentId,
    required this.senderId,
    required this.receiverId,
    required this.status,
  });

  factory Invitation.fromJSON(Map<String, dynamic> json) {
    return Invitation(
      id: json['id'],
      appointmentId: json['appointment_id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'appointment_id': appointmentId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'status': status,
    };
  }
}
