import 'package:barrani/constants.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barrani/controller/my_controller.dart';
import 'package:barrani/models/product.dart';

class ProductController extends MyController {
  List<Product> products = [];

  ProductController();

  @override
  void onInit() {
    super.onInit();
  }

  final allProductsStreamProvider = StreamProvider<List<Product>>((ref) {
    CollectionReference fireStoreQuery =
        Firestore.instance.collection(fireBaseCollections.products);
    return fireStoreQuery.stream.map((querySnapshot) {
      List<Product> products_ = [];

      for (var element in querySnapshot) {
        Map<String, dynamic> element_ = element.map;
        products_.add(Product.fromJSON(element_));
      }
      return products_;
    });
  });
}
