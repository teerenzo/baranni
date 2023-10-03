import 'package:barrani/constants.dart';
import 'package:barrani/models/category.dart';
import 'package:barrani/models/group.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barrani/models/product.dart';

final allProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  CollectionReference fireStoreQuery =
      Firestore.instance.collection(fireBaseCollections.products);
  return fireStoreQuery.stream.map((querySnapshot) {
    List<Product> products_ = [];

    for (var element in querySnapshot) {
      Map<String, dynamic> element_ = element.map;
      element_['id'] = element.id;
      products_.add(Product.fromJSON(element_));
    }
    return products_;
  });
});

final allCategoriesStreamProvider = StreamProvider<List<CategoryModal>>((ref) {
  CollectionReference fireStoreQuery =
      Firestore.instance.collection(fireBaseCollections.categories);
  return fireStoreQuery.stream.map((querySnapshot) {
    List<CategoryModal> categories = [];

    for (var element in querySnapshot) {
      Map<String, dynamic> element_ = element.map;
      element_['id'] = element.id;
      categories.add(CategoryModal.fromJSON(element_));
    }
    return categories;
  });
});

final allGroupsStreamProvider = StreamProvider<List<GroupModal>>((ref) {
  CollectionReference fireStoreQuery =
      Firestore.instance.collection(fireBaseCollections.groups);
  return fireStoreQuery.stream.map((querySnapshot) {
    List<GroupModal> groups = [];

    for (var element in querySnapshot) {
      Map<String, dynamic> element_ = element.map;
      element_['id'] = element.id;
      groups.add(GroupModal.fromJSON(element_));
    }
    return groups;
  });
});
