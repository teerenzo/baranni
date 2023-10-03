class Product {
  final String id, name, group, category, description, mainImgUrl;
  final double price, discountPercentage, discountPrice;
  final int stock, points;
  final List<String> images, productFeatures;
  final DateTime createdDate;
  Product(
    this.id,
    this.name,
    this.group,
    this.category,
    this.description,
    this.mainImgUrl,
    this.price,
    this.discountPercentage,
    this.discountPrice,
    this.stock,
    this.points,
    this.images,
    this.productFeatures,
    this.createdDate,
  );

  factory Product.fromJSON(Map<String, dynamic> json) {
    return Product(
      json['id'],
      json['name'],
      json['group'] ?? '',
      json['category_id'] ?? '',
      json['description'] ?? '',
      json['main_image_url'] ?? '',
      double.parse(json['price'].toString()),
      double.parse(json['discountPercentage'].toString()),
      double.parse(json['discountPrice'].toString()),
      int.parse(json['stock'].toString()),
      int.parse(json['points'].toString()),
      fromListDynamic(json['images']),
      fromListDynamic(json['product_features']),
      json['createdDate'],
    );
  }
}

List<String> fromListDynamic(List<dynamic>? data) {
  if (data == null) {
    return [];
  }
  return data.map((e) => e.toString()).toList();
}
