import 'dart:io';

import 'package:barrani/global_functions.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/firebase/product_provider.dart';
import 'package:barrani/helpers/firebase/product_provider_web_helper.dart';
import 'package:barrani/helpers/navigator_helper.dart';

import 'package:barrani/helpers/utils/utils.dart';
import 'package:barrani/helpers/widgets/my_text_style.dart';
import 'package:barrani/models/zone.dart';
import 'package:barrani/views/features/ecommerce/product_detail.dart';
import 'package:barrani/widgets/appointment_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/instance_manager.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:barrani/controller/ecommerce/product_controller.dart';
import 'package:barrani/helpers/extensions/string.dart';
import 'package:barrani/helpers/theme/app_style.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb_item.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/responsive.dart';
import 'package:barrani/models/product.dart';
import 'package:barrani/views/layouts/layout.dart';

class ZonePage extends ConsumerStatefulWidget {
  const ZonePage({Key? key}) : super(key: key);
  static const String routeName = "/zone/manage";

  @override
  ConsumerState<ZonePage> createState() => _ZonePageState();
}

class _ZonePageState extends ConsumerState<ZonePage>
    with SingleTickerProviderStateMixin, UIMixin {
  late ProductController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProductController());
  }

  @override
  Widget build(BuildContext context) {
    var products = ref.watch(
        kIsWeb ? allZonesStreamProviderWebHelper : allZonesStreamProvider);

    return Layout(
      child: Column(
        children: [
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium(
                  "Zones".tr(),
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'ecommerce'.tr()),
                    MyBreadcrumbItem(name: 'zones'.tr(), active: true),
                  ],
                ),
              ],
            ),
          ),
          MySpacing.height(flexSpacing),
          LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            return Padding(
              padding: MySpacing.x(flexSpacing),
              child: products.whenData((value) {
                return PaginatedDataTable(
                  source: MyData(
                      sortByDateZones(value
                          .where(
                              (element) => element.userId == userData!.userId)
                          .toList()),
                      context),
                  header: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText.titleMedium(
                        "Zone List",
                        fontWeight: 600,
                        fontSize: 20,
                      ),
                      MyButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) {
                                TextEditingController _nameController =
                                    TextEditingController();
                                bool _isLoading = false;
                                return LayoutBuilder(
                                  builder: (BuildContext context,
                                      BoxConstraints constraints) {
                                    return Dialog(
                                      child: SizedBox(
                                        width: 400,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: MySpacing.all(16),
                                              child: MyText.labelLarge(
                                                  'Add Zone'
                                                      .tr()
                                                      .capitalizeWords),
                                            ),
                                            const Divider(
                                                height: 0, thickness: 1),
                                            Padding(
                                              padding: MySpacing.all(16),
                                              child: Column(children: [
                                                TextFormField(
                                                  maxLines: 1,
                                                  controller: _nameController,
                                                  onChanged: (value) {},
                                                  decoration: InputDecoration(
                                                    hintText: "Zone 2",
                                                    hintStyle:
                                                        MyTextStyle.bodySmall(
                                                            xMuted: true),
                                                    border: outlineInputBorder,
                                                    enabledBorder:
                                                        outlineInputBorder,
                                                    focusedBorder:
                                                        focusedInputBorder,
                                                    contentPadding:
                                                        MySpacing.all(16),
                                                    isCollapsed: true,
                                                    floatingLabelBehavior:
                                                        FloatingLabelBehavior
                                                            .never,
                                                  ),
                                                ),
                                              ]),
                                            ),
                                            const Divider(
                                                height: 0, thickness: 1),
                                            Padding(
                                              padding: MySpacing.all(16),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  MyButton.rounded(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    elevation: 0,
                                                    padding:
                                                        MySpacing.xy(20, 16),
                                                    backgroundColor: theme
                                                        .colorScheme
                                                        .secondaryContainer,
                                                    child: MyText.labelMedium(
                                                      "close".tr(),
                                                      color: theme.colorScheme
                                                          .onSecondaryContainer,
                                                    ),
                                                  ),
                                                  MySpacing.width(16),
                                                  MyButton.rounded(
                                                    onPressed: () async {
                                                      if (_nameController
                                                          .text.isNotEmpty) {
                                                        setState(() {
                                                          _isLoading = true;
                                                        });
                                                        await FirebaseWebHelper
                                                            .addZone(
                                                                _nameController
                                                                    .text);
                                                        setState(() {
                                                          _isLoading = false;
                                                        });
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    elevation: 0,
                                                    padding:
                                                        MySpacing.xy(20, 16),
                                                    backgroundColor: theme
                                                        .colorScheme.primary,
                                                    child: MyText.labelMedium(
                                                      _isLoading
                                                          ? "saving"
                                                          : "save",
                                                      color: theme.colorScheme
                                                          .onPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              });
                        },
                        elevation: 0,
                        padding: MySpacing.xy(20, 16),
                        backgroundColor: contentTheme.primary,
                        borderRadiusAll: AppStyle.buttonRadius.medium,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.plus,
                              color: Color(0xffffffff),
                            ),
                            MySpacing.width(8),
                            MyText.labelMedium(
                              'Create Zone'.tr().capitalizeWords,
                              color: contentTheme.onPrimary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  columns: [
                    DataColumn(
                        label: MyText.titleMedium('Name', fontWeight: 600)),

                    DataColumn(
                        label:
                            MyText.titleMedium('Created At', fontWeight: 600)),
                    DataColumn(
                        label: MyText.titleMedium('Action', fontWeight: 600)),
                    // DataColumn(label: Text('Delete')),
                  ],
                  columnSpacing: 320,
                  horizontalMargin: 28,
                  rowsPerPage: 6,
                );
              }).when(data: (Widget data) {
                return data;
              }, error: (error, stack) {
                print(error);
                return Text(error.toString());
              }, loading: () {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

class MyData extends DataTableSource with UIMixin {
  List<PlaceZone> data = [];
  final BuildContext context;

  MyData(this.data, this.context);

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;

  @override
  DataRow getRow(int index) {
    return DataRow(
      cells: [
        DataCell(InkWell(
          onTap: () {},
          child: MyText.titleMedium(
            data[index].name.toString(),
            fontWeight: 600,
          ),
        )),
        DataCell(
          MyText.bodyMedium(
            '${Utils.getDateStringFromDateTime(
              data[index].createdDate!,
              showMonthShort: true,
            )}',
          ),
        ),
        DataCell(
          Align(
            alignment: Alignment.center,
            child: Row(
              children: [
                MyContainer.bordered(
                  onTap: () async => {
                    await FirebaseWebHelper.changeZoneStatus(
                        data[index].id,
                        data[index].show != null && data[index].show != false
                            ? false
                            : true),
                  },
                  padding: MySpacing.xy(6, 6),
                  borderColor: contentTheme.primary.withAlpha(40),
                  child: Icon(
                    (data[index].show != null && data[index].show != false)
                        ? LucideIcons.eye
                        : LucideIcons.eyeOff,
                    size: 12,
                    color: contentTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
