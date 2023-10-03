import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:barrani/controller/my_controller.dart';
import 'package:barrani/helpers/widgets/my_form_validator.dart';

enum Status {
  online,
  offline,
  draft;

  const Status();
}

class AddProductController extends MyController {
  MyFormValidator basicValidator = MyFormValidator();
  Status selectedGender = Status.online;
  List<PlatformFile> files = [];

  void removeFile(PlatformFile file) {
    files.remove(file);
    update();
  }

  @override
  void onInit() {
    super.onInit();
    basicValidator.addField(
      'name',
      label: "Product Name",
      required: true,
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'shop_name',
      label: "shop_name",
      required: true,
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'description',
      label: "description",
      required: true,
      controller: TextEditingController(),
    );
    basicValidator.addField(
      'tags',
      label: "Tags",
      required: true,
      controller: TextEditingController(),
    );
  }

  String selectedQuantity = "Fashion";

  void onSelectedQty(String qty) {
    selectedQuantity = qty;
    update();
  }

  bool showOnline = true;

  void setOnlineType(bool value) {
    showOnline = value;
    update();
  }

  final List<String> categories = [];

  void onChangeGender(Status? value) {
    selectedGender = value ?? selectedGender;
    update();
  }
}
