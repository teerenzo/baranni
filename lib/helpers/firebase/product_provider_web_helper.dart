import 'package:barrani/constants.dart';
import 'package:barrani/models/category.dart';
import 'package:barrani/models/group.dart';
import 'package:barrani/models/zone.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:barrani/models/product.dart';

final allProductsStreamProviderWebHelper = StreamProvider<List<Product>>((ref) {
  CollectionReference fireStoreQuery =
      FirebaseFirestore.instance.collection(fireBaseCollections.products);
  return fireStoreQuery.snapshots().map((querySnapshot) {
    List<Product> products_ = [];

    for (var element in querySnapshot.docs) {
      Map<String, dynamic> element_ = element.data() as Map<String, dynamic>;
      element_['id'] = element.id;
      Timestamp createdAt = element_['createdDate'];
      element_['createdDate'] = createdAt.toDate();
      products_.add(Product.fromJSON(element_));
    }
    return products_;
  });
});

final allZonesStreamProviderWebHelper = StreamProvider<List<PlaceZone>>((ref) {
  CollectionReference fireStoreQuery =
      FirebaseFirestore.instance.collection(fireBaseCollections.zones);
  return fireStoreQuery.snapshots().map((querySnapshot) {
    List<PlaceZone> zones = [];

    for (var element in querySnapshot.docs) {
      Map<String, dynamic> element_ = element.data() as Map<String, dynamic>;
      element_['id'] = element.id;
      element_['createdDate'] = element_['createdDate'].toDate();
      element_['userId'] = element_['userId'];
      zones.add(PlaceZone.fromJson(element_));
    }
    return zones;
  });
});

final allCategoriesStreamProviderWebHelper =
    StreamProvider<List<CategoryModal>>((ref) {
  CollectionReference fireStoreQuery =
      FirebaseFirestore.instance.collection(fireBaseCollections.categories);
  return fireStoreQuery.snapshots().map((querySnapshot) {
    List<CategoryModal> categories = [];

    for (var element in querySnapshot.docs) {
      Map<String, dynamic> element_ = element.data() as Map<String, dynamic>;
      element_['id'] = element.id;
      categories.add(CategoryModal.fromJSON(element_));
    }
    return categories;
  });
});

final allGroupsStreamProviderWebHelper =
    StreamProvider<List<GroupModal>>((ref) {
  CollectionReference fireStoreQuery =
      FirebaseFirestore.instance.collection(fireBaseCollections.groups);
  return fireStoreQuery.snapshots().map((querySnapshot) {
    List<GroupModal> groups = [];

    for (var element in querySnapshot.docs) {
      Map<String, dynamic> element_ = element.data() as Map<String, dynamic>;
      element_['id'] = element.id;
      groups.add(GroupModal.fromJSON(element_));
    }
    return groups;
  });
});
