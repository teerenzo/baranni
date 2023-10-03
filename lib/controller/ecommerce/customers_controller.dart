import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:barrani/controller/my_controller.dart';
import 'package:barrani/models/customer.dart';
import 'package:barrani/views/features/ecommerce/customers.dart';

class CustomersController extends MyController {
  List<Customer> customers = [];
  DataTableSource? data;

  CustomersController();

  int currentPage = 1;

  @override
  void onInit() {
    super.onInit();

    Customer.dummyList.then((value) {
      customers = value;
      data = MyData(customers);
      update();
    });
  }

  void goToDashboard() {
    Get.toNamed('/dashboard');
  }
}
