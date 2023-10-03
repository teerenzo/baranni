import 'package:barrani/global_functions.dart';
import 'package:barrani/helpers/firebase/product_provider.dart';
import 'package:barrani/helpers/firebase/product_provider_web_helper.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/helpers/utils/utils.dart';
import 'package:barrani/views/features/ecommerce/product_detail.dart';
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

class ProductPage extends ConsumerStatefulWidget {
  const ProductPage({Key? key}) : super(key: key);
  static const String routeName = "/ecommerce/products";

  @override
  ConsumerState<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends ConsumerState<ProductPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late ProductController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ProductController());
  }

  @override
  Widget build(BuildContext context) {
    var products = ref.watch(kIsWeb
        ? allProductsStreamProviderWebHelper
        : allProductsStreamProvider);
    return Layout(
      child: Column(
        children: [
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium(
                  "products".tr(),
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'ecommerce'.tr()),
                    MyBreadcrumbItem(name: 'products'.tr(), active: true),
                  ],
                ),
              ],
            ),
          ),
          MySpacing.height(flexSpacing),
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: products.whenData((value) {
              return PaginatedDataTable(
                source: MyData(sortByDate(value), context),
                header: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.titleMedium(
                      "Product List",
                      fontWeight: 600,
                      fontSize: 20,
                    ),
                    MyButton(
                      onPressed: () =>
                          NavigatorHelper.pushNamed('/ecommerce/add_product'),
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
                            'create_product'.tr().capitalizeWords,
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
                      label: MyText.titleMedium('Price', fontWeight: 600)),
                  DataColumn(
                      label: MyText.titleMedium('Rating', fontWeight: 600)),
                  DataColumn(
                      label: MyText.titleMedium('Stock', fontWeight: 600)),
                  DataColumn(
                      label: MyText.titleMedium('Points', fontWeight: 600)),
                  DataColumn(
                      label: MyText.titleMedium('Group', fontWeight: 600)),
                  DataColumn(
                      label: MyText.titleMedium('Created At', fontWeight: 600)),
                  DataColumn(
                      label: MyText.titleMedium('Action', fontWeight: 600)),
                  // DataColumn(label: Text('Delete')),
                ],
                columnSpacing: 110,
                horizontalMargin: 28,
                rowsPerPage: 10,
              );
            }).when(data: (Widget data) {
              return data;
            }, error: (error, stack) {
              print(error);
              return Container();
            }, loading: () {
              return Center(
                child: CircularProgressIndicator(),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class MyData extends DataTableSource with UIMixin {
  List<Product> data = [];
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
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ProductDetail(product: data[index])));
          },
          child: MyText.titleMedium(
            data[index].name.toString(),
            fontWeight: 600,
          ),
        )),
        DataCell(MyText.titleMedium(data[index].price.toString())),
        DataCell(MyText.titleMedium('0')),
        DataCell(MyText.titleMedium(data[index].stock.toString())),
        DataCell(MyText.titleMedium(data[index].points.toString())),
        DataCell(MyText.titleMedium(data[index].stock.toString())),
        DataCell(
          MyText.bodyMedium(
            '${Utils.getDateStringFromDateTime(
              data[index].createdDate,
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
                  onTap: () => {},
                  padding: MySpacing.xy(6, 6),
                  borderColor: contentTheme.primary.withAlpha(40),
                  child: Icon(
                    LucideIcons.edit2,
                    size: 12,
                    color: contentTheme.primary,
                  ),
                ),
                MySpacing.width(12),
                MyContainer.bordered(
                  onTap: () => {},
                  padding: MySpacing.xy(6, 6),
                  borderColor: contentTheme.primary.withAlpha(40),
                  child: Icon(
                    LucideIcons.trash2,
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
