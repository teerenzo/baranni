import 'package:barrani/controller/my_controller.dart';
import 'package:barrani/helpers/widgets/my_text_utils.dart';
import 'package:barrani/models/nft_dashboard_model.dart';

class NFTDashboardController extends MyController {
  List<String> dummyTexts =
      List.generate(12, (index) => MyTextUtils.getDummyText(60));

  List<NFTDashboardModel> nftDashboards = [];

  @override
  void onInit() {
    super.onInit();
    NFTDashboardModel.dummyList.then((value) {
      nftDashboards = value.sublist(0, 5);
      update();
    });
  }
}
