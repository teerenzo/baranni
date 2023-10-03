class PlaceZone {
  String id;
  String name;

  PlaceZone(
    this.id,
    this.name,
  );

  factory PlaceZone.fromJson(Map<String, dynamic> json) {
    return PlaceZone(
      json['id'],
      json['name'],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'name': name,
    };
  }
}
