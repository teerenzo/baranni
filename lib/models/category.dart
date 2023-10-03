class CategoryModal {
  final String id, color, image, name;

  const CategoryModal(this.id, this.color, this.image, this.name);

  factory CategoryModal.fromJSON(Map<String, dynamic> json) {
    return CategoryModal(
      json['id'],
      json['color'],
      json['image'],
      json['name'],
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      'id': id,
      'color': color,
      'image': image,
      'name': name,
    };
  }
}
