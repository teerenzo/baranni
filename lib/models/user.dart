class UserModal {
  final String email;
  final String names;
  final String userId;
  final String photoUrl;
  final String role;

  UserModal({
    required this.email,
    required this.names,
    required this.userId,
    required this.photoUrl,
    required this.role,
  });

  factory UserModal.fromJSON(Map<String, dynamic> json) {
    return UserModal(
      email: json['email'],
      names: json['names'] ?? '',
      userId: json['userId'],
      photoUrl: json['profile_url'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'email': email,
      'names': names,
      'userId': userId,
      'profile_url': photoUrl,
      'role': role,
    };
  }

  @override
  toString() {
    return 'User: $userId $email';
  }
}
