class PlaceZone {
  String id;
  String name;
  String? userId;
  DateTime? createdDate;

  PlaceZone(
    this.id,
    this.name,
    this.userId,
    this.createdDate,
  );

  factory PlaceZone.fromJson(Map<String, dynamic> json) {
    return PlaceZone(
        json['id'], json['name'], json['userId'], json['createdDate']);
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'createdDate': createdDate,
    };
  }
}
