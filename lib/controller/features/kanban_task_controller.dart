import 'package:barrani/controller/my_controller.dart';
import 'package:get/get.dart';

class KanbanTaskController extends MyController {
  // List<Product> products = [];
  // DataTableSource? data;

  KanbanTaskController();

  @override
  void onInit() {
    super.onInit();

    // Product.dummyList.then((value) {
    //   products = value;
    //   data = MyData(products);
    //   update();
    // });
  }

  void goToCreateKanbanTask() {
    Get.toNamed('/features/add_kanban_task');
  }
}
