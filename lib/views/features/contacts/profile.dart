// import 'package:barrani/controller/features/contact/profile_controller.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/helpers/theme/app_style.dart';
import 'package:barrani/helpers/utils/my_shadow.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb_item.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_card.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_flex.dart';
import 'package:barrani/helpers/widgets/my_flex_item.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/responsive.dart';
import 'package:barrani/images.dart';
import 'package:barrani/views/layouts/layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ProfilePage extends ConsumerStatefulWidget {
  static const routeName = "/contacts/profile";
  const ProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin, UIMixin {
  // late ProfileController controller;

  @override
  Widget build(BuildContext context) {
    ref.watch(kIsWeb
        ? FirebaseWebHelper.allUsersStreamProvider
        : allUsersStreamProvider);
    final projects = ref.watch(FirebaseWebHelper.projectsProvider);

    projects.when(
      data: (projects) {
        var userProjects =
            projects.where((project) => project.userId == userData?.userId);

        // Get the count of projects for the user
        projectCount = userProjects.length;

        // Return the project count
        return projectCount;
      },
      loading: () => Center(
        child: CircularProgressIndicator(),
      ), // Handle loading state if necessary
      error: (error, stackTrace) => Center(
          child: Text(
              'Error: ${error.toString()}')), // Handle error state if necessary
    );
    return Layout(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: MySpacing.x(flexSpacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.titleMedium(
                "Profile",
                fontWeight: 600,
              ),
              MyBreadcrumb(
                children: [
                  MyBreadcrumbItem(name: "Contact"),
                  MyBreadcrumbItem(name: "Profile", active: true),
                ],
              ),
            ],
          ),
        ),
        MySpacing.height(flexSpacing),
        Padding(
          padding: MySpacing.x(flexSpacing),
          child: MyFlex(
            contentPadding: false,
            children: [
              MyFlexItem(
                sizes: "lg-4",
                child: MyCard(
                  shadow: MyShadow(elevation: 0.5),
                  paddingAll: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyContainer(
                        paddingAll: 0,
                        borderRadiusAll: 4,
                        height: 205,
                        child: Stack(
                          children: [
                            Container(
                              height: 150,
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(4),
                                    topLeft: Radius.circular(4)),
                                gradient: LinearGradient(colors: [
                                  Color(0xff8360c3),
                                  Color(0xff6a82fb),
                                  Color(0xff6495ED),
                                  Color(0xff008088),
                                ], tileMode: TileMode.repeated),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: Padding(
                                padding: MySpacing.x(20),
                                child: userData?.photoUrl != null &&
                                        userData!.photoUrl.isNotEmpty
                                    ? MyContainer.rounded(
                                        paddingAll: 4,
                                        child: MyContainer.rounded(
                                          paddingAll: 0,
                                          height: 100,
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          child: Image.network(
                                            userData!.photoUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : MyContainer.rounded(
                                        paddingAll: 4,
                                        child: MyContainer.rounded(
                                          paddingAll: 0,
                                          height: 100,
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                          child: Image.asset(
                                            Images.avatars[0],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: MySpacing.x(32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyText.bodyMedium(
                                  userData!.names,
                                  fontWeight: 600,
                                  fontSize: 16,
                                ),
                                IconButton(
                                  onPressed: () {
                                    NavigatorHelper.pushNamed(
                                      '/contacts/edit-profile',
                                    );
                                    setState(() {});
                                  },
                                  icon: const Icon(
                                    LucideIcons.edit,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                            MyText.bodyMedium(userData!.email),
                          ],
                        ),
                      ),
                      MySpacing.height(12),
                      Padding(
                        padding: MySpacing.x(32),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          runAlignment: WrapAlignment.start,
                          runSpacing: 12,
                          spacing: 12,
                          children: [
                            buildButton(
                              "Design",
                              contentTheme.primary.withAlpha(30),
                              contentTheme.primary,
                            ),
                            buildButton(
                              "Management",
                              contentTheme.primary.withAlpha(30),
                              contentTheme.primary,
                            ),
                            buildButton(
                              "Ui Design",
                              contentTheme.primary.withAlpha(30),
                              contentTheme.primary,
                            ),
                            buildButton(
                              "Projects",
                              contentTheme.primary.withAlpha(30),
                              contentTheme.primary,
                            ),
                          ],
                        ),
                      ),
                      MySpacing.height(12),
                      Padding(
                        padding: MySpacing.x(32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(LucideIcons.users, size: 16),
                            MySpacing.width(8),
                            MyText.bodyMedium(
                              "128 Contacts",
                            ),
                            MySpacing.width(12),
                            Icon(LucideIcons.folderGit, size: 16),
                            MySpacing.width(8),
                            MyText.bodyMedium(
                              "$projectCount Projects",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              MyFlexItem(
                sizes: "lg-8",
                child: Column(
                  children: [
                    MyCard(
                      shadow: MyShadow(elevation: 0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.bodyLarge(
                            "About Us",
                            fontSize: 20,
                            fontWeight: 600,
                          ),
                          MySpacing.height(20),
                          MyText.bodyMedium(
                            "this is a demo text about me, i am a web developer and i love to create new web applications and websites.",
                            maxLines: 3,
                          ),
                          MySpacing.height(16),
                          MyFlex(
                            contentPadding: false,
                            children: [
                              MyFlexItem(
                                sizes: "lg-6",
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          LucideIcons.mapPin,
                                          size: 20,
                                        ),
                                        MySpacing.width(8),
                                        MyText.bodyMedium(
                                          "Live at Andorra",
                                        ),
                                      ],
                                    ),
                                    MySpacing.height(16),
                                    Row(
                                      children: [
                                        const Icon(
                                          LucideIcons.mail,
                                          size: 20,
                                        ),
                                        MySpacing.width(8),
                                        MyText.bodyMedium(
                                          "demo@gmail.com",
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              MyFlexItem(
                                sizes: "lg-6 sm-12",
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          LucideIcons.briefcase,
                                          size: 20,
                                        ),
                                        MySpacing.width(8),
                                        Expanded(
                                          child: MyText.bodyMedium(
                                            "Data Analyst at Gleichner, Mueller and Tromp",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    MySpacing.height(16),
                                    Row(
                                      children: [
                                        const Icon(
                                          LucideIcons.luggage,
                                          size: 20,
                                        ),
                                        MySpacing.width(8),
                                        Expanded(
                                          child: MyText.bodyMedium(
                                            "Studied at Nikolaus - Leuschke",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    MySpacing.height(16),
                    MyCard(
                      shadow: MyShadow(elevation: 0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.titleLarge(
                            "Social",
                            fontWeight: 600,
                          ),
                          MySpacing.height(16),
                          MyFlex(
                            children: [
                              MyFlexItem(
                                sizes: "lg-6 sm-12",
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const FaIcon(
                                          LucideIcons.facebook,
                                          color: Color(0xff3b5998),
                                        ),
                                        MySpacing.width(12),
                                        Expanded(
                                          child: MyText.bodyMedium(
                                            "https://www.facebook.com/caitlyn.kerluke",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    MySpacing.height(16),
                                    Row(
                                      children: [
                                        const FaIcon(
                                          LucideIcons.instagram,
                                          color: Color(0xffE4405F),
                                        ),
                                        MySpacing.width(12),
                                        Expanded(
                                          child: MyText.bodyMedium(
                                            "https://www.instagram.com/caitlyn.kerluke",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              MyFlexItem(
                                sizes: "lg-6",
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const FaIcon(
                                          LucideIcons.linkedin,
                                          color: Color(0xff0A66C2),
                                        ),
                                        MySpacing.width(8),
                                        Expanded(
                                          child: MyText.bodyMedium(
                                            "https://www.linkedIn.com/caitlyn.kerluke",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    MySpacing.height(16),
                                    Row(
                                      children: [
                                        const FaIcon(
                                          LucideIcons.twitter,
                                          color: Color(0xff00acee),
                                        ),
                                        MySpacing.width(8),
                                        Expanded(
                                          child: MyText.bodyMedium(
                                            "https://www.twitter.com/caitlyn.kerluke",
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    MySpacing.height(16),
                    MyCard(
                      shadow: MyShadow(elevation: 0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText.bodyLarge(
                            "Reviews",
                            fontSize: 20,
                            fontWeight: 600,
                          ),
                          MySpacing.height(12),
                          // SfCartesianChart(
                          //   primaryXAxis: NumericAxis(isInversed: true),
                          //   primaryYAxis: NumericAxis(isInversed: true),
                          //   tooltipBehavior: controller.tool,
                          //   series: <ChartSeries<ChartData, double>>[
                          //     LineSeries<ChartData, double>(
                          //       dataSource: controller.chartData,
                          //       markerSettings:
                          //           const MarkerSettings(isVisible: true),
                          //       xValueMapper: (ChartData data, _) =>
                          //           data.x,
                          //       yValueMapper: (ChartData data, _) =>
                          //           data.y,
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget buildWorkHistory(String productType, String productName) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MyText.bodyMedium(
                  productType,
                ),
              ],
            ),
            MyText.bodyMedium(
              productName,
            ),
          ],
        )
      ],
    );
  }

  Widget buildButton(String buttonName, Color colors, Color textColor) {
    return MyButton(
      onPressed: () {},
      elevation: 0,
      padding: MySpacing.xy(16, 8),
      borderColor: textColor,
      backgroundColor: colors,
      splashColor: colors,
      borderRadiusAll: AppStyle.buttonRadius.medium,
      child: MyText.bodySmall(
        buttonName,
        color: textColor,
      ),
    );
  }
}
