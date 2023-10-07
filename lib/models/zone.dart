class PlaceZone {
  String id;
  String name;
  String? userId;
  DateTime? createdDate;
  bool? show;

  PlaceZone(
    this.id,
    this.name,
    this.userId,
    this.createdDate,
    this.show,
  );

  factory PlaceZone.fromJson(Map<String, dynamic> json) {
    return PlaceZone(json['id'], json['name'], json['userId'],
        json['createdDate'], json['show']);
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'name': name,
      'userId': userId,
      'createdDate': createdDate,
      'show': show,
    };
  }
}
