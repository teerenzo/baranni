class GroupModal {
  final String id, image, name, slag;

  const GroupModal(this.id, this.image, this.name, this.slag);

  factory GroupModal.fromJSON(Map<String, dynamic> json) {
    return GroupModal(
      json['id'],
      json['image'],
      json['name'],
      json['slag'],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'image': image,
      'name': name,
      'slag': slag,
    };
  }
}
