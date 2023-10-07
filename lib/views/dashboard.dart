import 'package:barrani/data/providers/ui/dashboard_provider.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/extensions/string.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';

import 'package:barrani/helpers/theme/theme_provider.dart';
import 'package:barrani/helpers/utils/my_shadow.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb_item.dart';
import 'package:barrani/helpers/widgets/my_card.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_dotted_line.dart';
import 'package:barrani/helpers/widgets/my_flex.dart';
import 'package:barrani/helpers/widgets/my_flex_item.dart';
import 'package:barrani/helpers/widgets/my_list_extension.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/responsive.dart';
import 'package:barrani/views/layouts/layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardPage extends ConsumerStatefulWidget {
  static const routeName = '/dashboard';
  const DashboardPage({super.key});

  @override
  DashboardPageState createState() => DashboardPageState();
}

class DashboardPageState extends ConsumerState<DashboardPage>
    with SingleTickerProviderStateMixin, UIMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dashProvider = ref.watch(dashboardProvider);
    ref.watch(kIsWeb
        ? FirebaseWebHelper.allUsersStreamProvider
        : allUsersStreamProvider);
    ref.watch(kIsWeb
        ? FirebaseWebHelper.allAppointmentsStreamProvider
        : allAppointmentsStreamProvider);
    ref.watch(kIsWeb
        ? FirebaseWebHelper.allInvitationsStreamProvider
        : allInvitationsStreamProvider);
    ref.watch(kIsWeb
        ? FirebaseWebHelper.allZonesStreamProvider
        : allZonesStreamProvider);
    ref.watch(kIsWeb
        ? FirebaseWebHelper.userNotificationsStreamProvider
        : userNotificationsStreamProvider);
    ref.watch(themesProvider);
    return Layout(
        child: Column(
      children: [
        Padding(
          padding: MySpacing.x(flexSpacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.titleMedium(
                "dashboard".tr(),
                fontSize: 18,
                fontWeight: 600,
                color: contentTheme.onBackground,
              ),
              MyBreadcrumb(
                children: [
                  MyBreadcrumbItem(name: 'dashboard'.tr(), active: true),
                ],
              ),
            ],
          ),
        ),
        MySpacing.height(flexSpacing),
        Padding(
          padding: MySpacing.x(flexSpacing / 2),
          child: MyFlex(
            runAlignment: WrapAlignment.start,
            wrapCrossAlignment: WrapCrossAlignment.start,
            // contentPadding: false,
            children: [
              MyFlexItem(
                child: MyFlex(
                  wrapAlignment: WrapAlignment.spaceBetween,
                  runAlignment: WrapAlignment.start,
                  wrapCrossAlignment: WrapCrossAlignment.start,
                  contentPadding: false,
                  children: [
                    MyFlexItem(
                      sizes: "lg-8",
                      child: MyFlex(
                        runAlignment: WrapAlignment.start,
                        wrapCrossAlignment: WrapCrossAlignment.start,
                        contentPadding: false,
                        children: [
                          MyFlexItem(
                            sizes: "lg-4",
                            child: buildCard(
                                contentTheme.warning.withAlpha(28),
                                LucideIcons.clock4,
                                "Reached",
                                "\$152",
                                LucideIcons.trendingUp,
                                contentTheme.success,
                                "1.25",
                                "Last Month"),
                          ),
                          MyFlexItem(
                            sizes: "lg-4",
                            child: buildCard(
                              contentTheme.primary,
                              LucideIcons.network,
                              "Engaged",
                              "\$50",
                              LucideIcons.trendingDown,
                              contentTheme.red,
                              "2.5",
                              "Last Week",
                            ),
                          ),
                          MyFlexItem(
                            sizes: "lg-4",
                            child: buildCard(
                                contentTheme.success,
                                LucideIcons.areaChart,
                                "Rich",
                                "\$304",
                                LucideIcons.trendingDown,
                                contentTheme.red,
                                "1.23",
                                "Last Month"),
                          ),
                          MyFlexItem(
                            sizes: "lg-4",
                            child: buildCard(
                                contentTheme.warning,
                                LucideIcons.shoppingCart,
                                "Engagement",
                                "\$189",
                                LucideIcons.trendingUp,
                                contentTheme.success,
                                "0.2",
                                "Last Day"),
                          ),
                          MyFlexItem(
                            sizes: "lg-4",
                            child: buildCard(
                                contentTheme.info,
                                LucideIcons.calendar,
                                "Appointments",
                                "\$189",
                                LucideIcons.trendingUp,
                                contentTheme.success,
                                "0.2",
                                "Last Day"),
                          ),
                          MyFlexItem(
                            sizes: "lg-4",
                            child: buildCard(
                                contentTheme.success,
                                LucideIcons.messageCircle,
                                "Information",
                                "\$189",
                                LucideIcons.trendingUp,
                                contentTheme.success,
                                "0.2",
                                "Last Day"),
                          ),
                        ],
                      ),
                    ),
                    MyFlexItem(
                      sizes: "lg-4",
                      child: MyCard(
                        shadow: MyShadow(elevation: 0.5),
                        height: 305,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        padding: MySpacing.only(left: 24, right: 12, top: 12),
                        color: theme.colorScheme.background,
                        child: Stack(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          children: [
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText.titleMedium(
                                          "New Visitors",
                                          color: theme.colorScheme.onBackground,
                                          fontWeight: 600,
                                        ),
                                        MySpacing.width(8),
                                        MyContainer(
                                          padding: MySpacing.xy(12, 2),
                                          color: contentTheme.success,
                                          child: MyText.bodyMedium(
                                            "Active",
                                            fontSize: 12,
                                            color: contentTheme.onSuccess,
                                          ),
                                        )
                                      ],
                                    ),
                                    IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          LucideIcons.moveRight,
                                          size: 16,
                                          color: theme.colorScheme.secondary,
                                        ))
                                  ],
                                ),
                                MySpacing.height(16),
                                Row(
                                  children: [
                                    MyDottedLine(
                                      height: 50,
                                      dottedLength: 1,
                                      color: Colors.grey.shade400,
                                      child: Padding(
                                        padding: MySpacing.xy(12, 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyText.bodyMedium(
                                              "\$5,943",
                                              fontSize: 20,
                                              color: theme.colorScheme.tertiary,
                                            ),
                                            MySpacing.height(8),
                                            MyText.bodyMedium(
                                              "New Followers",
                                              color:
                                                  theme.colorScheme.onTertiary,
                                              fontWeight: 600,
                                              muted: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    MySpacing.width(16),
                                    MyDottedLine(
                                      height: 50,
                                      dottedLength: 1,
                                      color: Colors.grey.shade400,
                                      child: Padding(
                                        padding: MySpacing.xy(12, 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            MyText.bodyMedium(
                                              "150,000",
                                              fontSize: 20,
                                              color: theme
                                                  .colorScheme.onBackground,
                                            ),
                                            MySpacing.height(8),
                                            MyText.bodyMedium(
                                              "Followers Goal",
                                              color: theme
                                                  .colorScheme.onBackground,
                                              fontWeight: 600,
                                              muted: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            MySpacing.height(16),
                            Positioned(
                              right: 0,
                              left: 0,
                              top: 100,
                              child: SfCartesianChart(
                                plotAreaBorderWidth: 0,
                                tooltipBehavior: dashProvider.facebook,
                                primaryXAxis: CategoryAxis(
                                  isVisible: false,
                                  majorGridLines:
                                      const MajorGridLines(width: 0),
                                  labelStyle: const TextStyle(fontSize: 0),
                                ),
                                primaryYAxis: NumericAxis(
                                    isVisible: false,
                                    labelStyle: const TextStyle(fontSize: 0),
                                    majorGridLines:
                                        const MajorGridLines(width: 0)),
                                series: <ChartSeries<ChartSampleData, int>>[
                                  ColumnSeries<ChartSampleData, int>(
                                    width: 0.5,
                                    color: contentTheme.primary,
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    dataSource: dashProvider.facebookChart,
                                    xValueMapper: (ChartSampleData data, _) =>
                                        data.x,
                                    yValueMapper: (ChartSampleData data, _) =>
                                        data.y,
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              MyFlexItem(
                child: MyFlex(
                  runAlignment: WrapAlignment.start,
                  wrapCrossAlignment: WrapCrossAlignment.start,
                  contentPadding: false,
                  children: [
                    MyFlexItem(
                      sizes: "lg-8 xl-8",
                      child: MyCard(
                        shadow: MyShadow(elevation: 0.5),
                        paddingAll: 0,
                        child: Column(
                          children: [
                            Padding(
                              padding: MySpacing.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: MyText.titleMedium(
                                      "Response time by location",
                                      overflow: TextOverflow.ellipsis,
                                      fontWeight: 600,
                                    ),
                                  ),
                                  PopupMenuButton(
                                    onSelected: ref
                                        .read(dashboardProvider.notifier)
                                        .onSelectedTimeByLocation,
                                    itemBuilder: (BuildContext context) {
                                      return [
                                        "Year",
                                        "Month",
                                        "Week",
                                        "Day",
                                        "Hours"
                                      ].map((behavior) {
                                        return PopupMenuItem(
                                          value: behavior,
                                          height: 32,
                                          child: MyText.bodySmall(
                                            behavior.toString(),
                                            color:
                                                theme.colorScheme.onBackground,
                                            fontWeight: 600,
                                          ),
                                        );
                                      }).toList();
                                    },
                                    color: theme.cardTheme.color,
                                    child: MyContainer.bordered(
                                      padding: MySpacing.xy(12, 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          MyText.labelMedium(
                                            dashProvider.selectedTimeByLocation
                                                .toString(),
                                            color:
                                                theme.colorScheme.onBackground,
                                          ),
                                          Icon(
                                            LucideIcons.chevronDown,
                                            size: 22,
                                            color:
                                                theme.colorScheme.onBackground,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            MySpacing.height(12),
                            MyFlex(
                              children: [
                                MyFlexItem(
                                  sizes: "lg-3",
                                  child: buildResponseTimeByLocationData(
                                    "Current Week",
                                    "\$1859.52",
                                    LucideIcons.cornerRightUp,
                                    contentTheme.success,
                                  ),
                                ),
                                MyFlexItem(
                                  sizes: "lg-3",
                                  child: buildResponseTimeByLocationData(
                                    "Previous Week",
                                    "\$1568",
                                    LucideIcons.cornerRightDown,
                                    contentTheme.red,
                                  ),
                                ),
                                MyFlexItem(
                                  sizes: "lg-3",
                                  child: buildResponseTimeByLocationData(
                                    "Conversation",
                                    "5.68%",
                                    LucideIcons.cornerRightUp,
                                    contentTheme.success,
                                  ),
                                ),
                                MyFlexItem(
                                  sizes: "lg-3",
                                  child: buildResponseTimeByLocationData(
                                    "Customers",
                                    "80K",
                                    LucideIcons.cornerRightDown,
                                    contentTheme.red,
                                  ),
                                ),
                              ],
                            ),
                            MySpacing.height(12),
                            const Divider(),
                            Padding(
                              padding: MySpacing.all(16),
                              child: SfCartesianChart(
                                primaryXAxis: CategoryAxis(),
                                tooltipBehavior: dashProvider.chart,
                                axes: <ChartAxis>[
                                  NumericAxis(
                                      numberFormat: NumberFormat.compact(),
                                      majorGridLines:
                                          const MajorGridLines(width: 0),
                                      opposedPosition: true,
                                      name: 'yAxis1',
                                      interval: 1000,
                                      minimum: 0,
                                      maximum: 7000)
                                ],
                                series: <ChartSeries<ChartSampleData, String>>[
                                  ColumnSeries<ChartSampleData, String>(
                                      animationDuration: 2000,
                                      width: 0.5,
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4)),
                                      color: contentTheme.primary,
                                      dataSource: dashProvider.chartData,
                                      xValueMapper: (ChartSampleData data, _) =>
                                          data.x,
                                      yValueMapper: (ChartSampleData data, _) =>
                                          data.y,
                                      name: 'Unit Sold'),
                                  LineSeries<ChartSampleData, String>(
                                      animationDuration: 4500,
                                      animationDelay: 2000,
                                      dataSource: dashProvider.chartData,
                                      xValueMapper: (ChartSampleData data, _) =>
                                          data.x,
                                      yValueMapper: (ChartSampleData data, _) =>
                                          data.yValue,
                                      yAxisName: 'yAxis1',
                                      markerSettings:
                                          const MarkerSettings(isVisible: true),
                                      name: 'Total Transaction')
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    MyFlexItem(
                        sizes: "lg-4",
                        child: MyCard(
                          shadow: MyShadow(elevation: 0.5),
                          paddingAll: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  MyText.titleMedium(
                                    "Cost BreakDown",
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: 600,
                                  ),
                                  IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        LucideIcons.moveRight,
                                        size: 20,
                                      ))
                                ],
                              ),
                              SfCircularChart(
                                tooltipBehavior: TooltipBehavior(enable: true),
                                series: <CircularSeries>[
                                  DoughnutSeries<ChartSampleData, String>(
                                      radius: '80%',
                                      explode: true,
                                      explodeOffset: '10%',
                                      dataSource: dashProvider.circleChart,
                                      pointColorMapper:
                                          (ChartSampleData data, _) =>
                                              data.pointColor,
                                      xValueMapper: (ChartSampleData data, _) =>
                                          data.x,
                                      yValueMapper: (ChartSampleData data, _) =>
                                          data.y,
                                      dataLabelSettings:
                                          const DataLabelSettings(
                                              isVisible: true)),
                                ],
                              ),
                              // MySpacing.height(12),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      MyText.titleMedium("Top Channel"),
                                      MyText.titleMedium("Value")
                                    ],
                                  ),
                                  MySpacing.height(12),
                                  buildCircleChartData(
                                      const Color.fromRGBO(9, 0, 136, 1),
                                      "Salary",
                                      "\$41,458"),
                                  MySpacing.height(8),
                                  buildCircleChartData(
                                      const Color.fromRGBO(147, 0, 119, 1),
                                      "Bill",
                                      "\$48,125"),
                                  MySpacing.height(8),
                                  buildCircleChartData(
                                      const Color.fromRGBO(228, 0, 124, 1),
                                      "Marketing",
                                      "\$19,458"),
                                  MySpacing.height(8),
                                  buildCircleChartData(
                                      const Color.fromRGBO(255, 189, 57, 1),
                                      "Other",
                                      "\$10,589"),
                                ],
                              )
                            ],
                          ),
                        ))
                  ],
                ),
              ),
              MyFlexItem(
                child: MyFlex(
                  contentPadding: false,
                  children: [
                    MyFlexItem(
                      sizes: "lg-6",
                      child: MyCard(
                        shadow: MyShadow(elevation: 0.5),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                MyText.titleMedium(
                                  "High Value Design",
                                  fontWeight: 600,
                                ),
                                Row(
                                  children: [
                                    PopupMenuButton(
                                      onSelected: ref
                                          .read(dashboardProvider.notifier)
                                          .onSelectedTimeDesign,
                                      itemBuilder: (BuildContext context) {
                                        return [
                                          "Year",
                                          "Month",
                                          "Week",
                                          "Day",
                                          "Hours",
                                        ].map((behavior) {
                                          return PopupMenuItem(
                                            value: behavior,
                                            height: 32,
                                            child: MyText.bodySmall(
                                              behavior.toString(),
                                              color: theme
                                                  .colorScheme.onBackground,
                                              fontWeight: 600,
                                            ),
                                          );
                                        }).toList();
                                      },
                                      color: theme.cardTheme.color,
                                      child: MyContainer.bordered(
                                        padding: MySpacing.xy(12, 8),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            MyText.labelMedium(
                                              dashProvider.selectedTimeDesign
                                                  .toString(),
                                              color: theme
                                                  .colorScheme.onBackground,
                                            ),
                                            Icon(
                                              LucideIcons.chevronDown,
                                              size: 22,
                                              color: theme
                                                  .colorScheme.onBackground,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            MySpacing.height(16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: MyContainer.bordered(
                                paddingAll: 0,
                                child: DataTable(
                                    sortAscending: true,
                                    onSelectAll: (_) => {},
                                    headingRowColor: MaterialStatePropertyAll(
                                        contentTheme.primary.withAlpha(40)),
                                    dataRowMaxHeight: 50,
                                    columns: [
                                      DataColumn(
                                        label: MyText.labelLarge(
                                          'Value',
                                        ),
                                      ),
                                      DataColumn(
                                        label: MyText.labelLarge(
                                          'Sum',
                                        ),
                                      ),
                                      DataColumn(
                                        label: MyText.labelLarge(
                                          'Metric',
                                        ),
                                      ),
                                      DataColumn(
                                        label: MyText.labelLarge(
                                          'Tag',
                                        ),
                                      ),
                                    ],
                                    rows: dashProvider.dashboard
                                        .mapIndexed(
                                          (index, data) => DataRow(
                                            cells: [
                                              DataCell(
                                                MyText.bodyMedium(
                                                    "${data.value}"),
                                              ),
                                              DataCell(
                                                MyText.bodyMedium(
                                                    "${data.sum}"),
                                              ),
                                              DataCell(
                                                Row(
                                                  children: [
                                                    MyContainer(
                                                      paddingAll: 0,
                                                      borderRadiusAll: 22,
                                                      clipBehavior: Clip
                                                          .antiAliasWithSaveLayer,
                                                      child: Image.asset(
                                                        dashProvider
                                                            .dashboard[index]
                                                            .image,
                                                        height: 32,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                    MySpacing.width(16),
                                                    Expanded(
                                                      child: MyText.bodyMedium(
                                                        data.metric,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              DataCell(
                                                MyText.bodyMedium(data.tag),
                                              ),
                                            ],
                                          ),
                                        )
                                        .toList()),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    MyFlexItem(
                      sizes: "lg-6",
                      child: MyCard(
                        shadow: MyShadow(elevation: 0.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: MySpacing.x(8),
                                  child: MyText.titleMedium(
                                    "Revenue Chart",
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: 600,
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {},
                                    icon: const Icon(
                                      LucideIcons.moveRight,
                                      size: 20,
                                    ))
                              ],
                            ),
                            MySpacing.height(16),
                            SizedBox(
                              height: 308,
                              child: SfCartesianChart(
                                plotAreaBorderWidth: 0,
                                tooltipBehavior: dashProvider.revenue,
                                primaryXAxis: CategoryAxis(
                                  majorGridLines:
                                      const MajorGridLines(width: 0),
                                ),
                                primaryYAxis: NumericAxis(
                                    // majorGridLines:
                                    // const MajorGridLines(width: 0),
                                    ),
                                series: <ChartSeries>[
                                  SplineSeries<ChartSampleData, String>(
                                    color: const Color(0xff727cf5),
                                    dataLabelSettings: const DataLabelSettings(
                                      borderWidth: 100,
                                      showZeroValue: true,
                                    ),
                                    dataSource: dashProvider.revenueChart1,
                                    xValueMapper: (ChartSampleData data, _) =>
                                        data.x,
                                    yValueMapper: (ChartSampleData data, _) =>
                                        data.y,
                                  ),
                                  SplineSeries<ChartSampleData, String>(
                                    color: const Color(0xff0acf97),
                                    dataSource: dashProvider.revenueChart2,
                                    xValueMapper: (ChartSampleData data, _) =>
                                        data.x,
                                    yValueMapper: (ChartSampleData data, _) =>
                                        data.y,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget buildCircleChartData(Color color, String name, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MyContainer.rounded(
              paddingAll: 4,
              color: color,
            ),
            MySpacing.width(8),
            MyText.bodyMedium(name)
          ],
        ),
        MyText.bodyMedium(price),
      ],
    );
  }

  Widget buildResponseTimeByLocationData(
      String currentTime, String price, IconData icon, Color iconColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              LucideIcons.circleDotDashed,
              size: 16,
            ),
            MySpacing.width(8),
            MyText.bodyMedium(
              currentTime,
            ),
          ],
        ),
        MySpacing.height(12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyText.bodyLarge(
              price,
              fontSize: 20,
              fontWeight: 600,
              muted: true,
            ),
            MySpacing.width(8),
            Icon(
              icon,
              size: 16,
              color: iconColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCard(
    Color color,
    IconData icons,
    String accountType,
    String price,
    IconData trendingIcon,
    Color trendingIconColor,
    String percentage,
    String month,
  ) {
    return MyCard(
      shadow: MyShadow(elevation: 0.5),
      height: 140,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText.bodyLarge(
                  accountType,
                  fontSize: 15,
                  fontWeight: 600,
                ),
                MyText.bodyLarge(
                  price,
                  fontWeight: 600,
                  fontSize: 20,
                ),
                Row(
                  children: [
                    Icon(
                      trendingIcon,
                      color: trendingIconColor,
                      size: 16,
                    ),
                    MySpacing.width(8),
                    MyText.bodyMedium(
                      "$percentage%",
                    ),
                    MySpacing.width(8),
                    Expanded(
                      child: MyText.bodyMedium(
                        month,
                        overflow: TextOverflow.ellipsis,
                        muted: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          MyContainer(
            height: 70,
            width: 70,
            paddingAll: 0,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            color: color.withAlpha(30),
            child: Icon(
              icons,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
