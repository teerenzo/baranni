import 'package:barrani/controller/my_controller.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/helpers/widgets/my_text_utils.dart';
import 'package:barrani/images.dart';
import 'package:barrani/models/project_list.dart';

class ProjectListController extends MyController {
  List<ProjectList> projectList = [];
  List<String> dummyTexts =
      List.generate(12, (index) => MyTextUtils.getDummyText(60));
  List<String> images = [
    Images.avatars[0],
    Images.avatars[1],
    Images.avatars[2],
    Images.avatars[3],
  ];

  @override
  void onInit() {
    super.onInit();
    ProjectList.dummyList.then((value) {
      projectList = value.sublist(0, 7);
      update();
    });
  }

  void goToCreateProject() {
    NavigatorHelper.pushNamed('/projects/create-project');
  }
}
