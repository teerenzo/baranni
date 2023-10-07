import 'package:barrani/controller/layouts/auth_layout_controller.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/theme/admin_theme.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_flex.dart';
import 'package:barrani/helpers/widgets/my_flex_item.dart';
import 'package:barrani/helpers/widgets/my_responsiv.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class AuthLayout extends StatelessWidget {
  final Widget? child;
  final contentTheme = AdminTheme.theme.contentTheme;

  final AuthLayoutController controller = AuthLayoutController();

  AuthLayout({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return MyResponsive(builder: (BuildContext context, _, screenMT) {
      return GetBuilder(
          init: controller,
          builder: (controller) {
            return screenMT.isMobile
                ? mobileScreen(context)
                : largeScreen(context);
          });
    });
  }

  Widget mobileScreen(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      body: Container(
        padding: MySpacing.top(MySpacing.safeAreaTop(context) + 20),
        height: MediaQuery.of(context).size.height,
        color: theme.cardTheme.color,
        child: SingleChildScrollView(
          key: controller.scrollKey,
          child: child,
        ),
      ),
    );
  }

  Widget largeScreen(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      backgroundColor: theme.colorScheme.background,
      body: Stack(
        children: [
          Container(
            margin: MySpacing.top(100),
            width: MediaQuery.of(context).size.width,
            child: MyFlex(
              wrapAlignment: WrapAlignment.center,
              wrapCrossAlignment: WrapCrossAlignment.start,
              runAlignment: WrapAlignment.center,
              spacing: 0,
              runSpacing: 0,
              children: [
                MyFlexItem(
                  sizes: "xxl-8 lg-8 md-9 sm-10",
                  // sizes: "xxl-3 lg-4 md-6 sm-8",
                  child: MyContainer(
                    paddingAll: 0,
                    child: child ?? Container(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
