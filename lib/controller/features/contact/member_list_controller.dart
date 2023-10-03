import 'package:barrani/controller/my_controller.dart';
import 'package:barrani/helpers/widgets/my_form_validator.dart';
import 'package:barrani/models/discover.dart';
import 'package:barrani/models/opportunities.dart';

class MemberListController extends MyController {
  List<Discover> discover = [];
  List<Opportunities> opportunities = [];

  MyFormValidator basicValidator = MyFormValidator();
  bool loading = false;

  @override
  void onInit() {
    super.onInit();

    Discover.dummyList.then((value) {
      discover = value.sublist(0, 7);
      update();
    });
    Opportunities.dummyList.then((value) {
      opportunities = value.sublist(0, 7);
      update();
    });
  }
}
