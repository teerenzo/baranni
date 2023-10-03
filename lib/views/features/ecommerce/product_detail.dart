import 'package:barrani/helpers/extensions/extensions.dart';
import 'package:barrani/models/product.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb_item.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_flex.dart';
import 'package:barrani/helpers/widgets/my_flex_item.dart';
import 'package:barrani/helpers/widgets/my_progress_bar.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/responsive.dart';
import 'package:barrani/helpers/widgets/my_list_extension.dart';
import 'package:barrani/views/layouts/layout.dart';
import 'package:barrani/controller/ecommerce/product_detail_controller.dart';

class ProductDetail extends StatefulWidget {
  static const String routeName = "/ecommerce/product-detail";
  final Product product;
  const ProductDetail({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail>
    with SingleTickerProviderStateMixin, UIMixin {
  late ProductDetailController controller;
  late String selectedImgUrl;

  @override
  void initState() {
    super.initState();
    selectedImgUrl = widget.product.mainImgUrl;
    controller = Get.put(ProductDetailController());
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Column(
        children: [
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium(
                  "Product Detail",
                  fontWeight: 600,
                  fontSize: 18,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: "Ecommerce"),
                    MyBreadcrumbItem(name: "Product Detail", active: true),
                  ],
                ),
              ],
            ),
          ),
          MySpacing.height(flexSpacing),
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: MyContainer(
              child: MyFlex(
                contentPadding: false,
                wrapAlignment: WrapAlignment.start,
                wrapCrossAlignment: WrapCrossAlignment.start,
                children: [
                  MyFlexItem(
                    sizes: "lg-4",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        MyContainer(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          paddingAll: 0,
                          child: Image.network(
                            selectedImgUrl,
                            fit: BoxFit.cover,
                            height: 500,
                          ),
                        ),
                        MySpacing.height(16),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runSpacing: 12,
                          spacing: 14,
                          children: widget.product.images
                              .mapIndexed(
                                (index, image) => MyContainer.bordered(
                                  onTap: () {
                                    setState(() {
                                      selectedImgUrl = image;
                                    });
                                  },
                                  height: 100,
                                  bordered: image == selectedImgUrl,
                                  border: Border.all(
                                    color: contentTheme.primary,
                                    width: 2,
                                  ),
                                  paddingAll: 0,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Image.network(
                                    image,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                        MySpacing.height(20),
                        MyContainer.bordered(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText.bodyMedium(
                                "Detail".tr().capitalizeWords,
                                fontSize: 16,
                                fontWeight: 600,
                              ),
                              MySpacing.height(20),
                              const Divider(),
                              buildDetail(
                                "price".tr().capitalizeWords,
                                '\$${widget.product.price}',
                              ),
                              const Divider(),
                              buildDetail(
                                "discount percentage".tr().capitalizeWords,
                                widget.product.discountPercentage.toString(),
                              ),
                              const Divider(),
                              buildDetail(
                                "discount price".tr().capitalizeWords,
                                widget.product.discountPrice.toString(),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  MyFlexItem(
                    sizes: "lg-8",
                    child: Padding(
                      padding: MySpacing.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    LucideIcons.badgeCheck,
                                    color: contentTheme.primary,
                                  ),
                                  MySpacing.width(8),
                                  MyText.bodyMedium(
                                    "Verified",
                                    color: contentTheme.primary,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  MyContainer(
                                    color: !controller.showLike
                                        ? contentTheme.red.withAlpha(30)
                                        : contentTheme.dark.withAlpha(30),
                                    paddingAll: 0,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: IconButton(
                                      onPressed: () {
                                        controller.onChangeLike();
                                      },
                                      icon: Icon(Icons.delete,
                                          size: 24,
                                          color: !controller.showLike
                                              ? contentTheme.red
                                              : contentTheme.dark),
                                    ),
                                  ),
                                  MySpacing.width(16),
                                  MyContainer(
                                    color: contentTheme.success.withAlpha(30),
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    paddingAll: 0,
                                    child: IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        LucideIcons.pencil,
                                        color: contentTheme.success,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                          MySpacing.height(20),
                          MyText.titleLarge(
                            widget.product.name,
                            fontSize: 32,
                            fontWeight: 600,
                          ),
                          MySpacing.height(20),
                          MyText.bodyMedium(
                            widget.product.description,
                            maxLines: 3,
                          ),
                          MySpacing.height(24),
                          MyContainer.bordered(
                            width: double.infinity,
                            // borderRadiusAll: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText.bodyMedium(
                                  "Attribute",
                                  fontSize: 16,
                                ),
                                MySpacing.height(16),
                                Wrap(
                                  spacing: 20,
                                  runSpacing: 20,
                                  runAlignment: WrapAlignment.spaceBetween,
                                  alignment: WrapAlignment.spaceBetween,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    buildAttributeContainer(
                                      "Background",
                                      "bg-plain-granite",
                                    ),
                                    buildAttributeContainer(
                                      "Level",
                                      "Level 99",
                                    ),
                                    buildAttributeContainer(
                                      "Body",
                                      "Grey Crawler",
                                    ),
                                  ],
                                )
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
          ),
        ],
      ),
    );
  }

  Widget buildAttributeContainer(String title, String subtitle) {
    return MyContainer(
      width: 150,
      color: contentTheme.primary.withAlpha(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.bodyMedium(
            title,
            muted: true,
          ),
          MyText.bodyMedium(
            subtitle,
            fontWeight: 600,
            color: contentTheme.primary,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget buildDetail(String title, String subTitle) {
    return Row(
      children: [
        Expanded(
          child: MyText.bodyMedium(
            title,
            fontWeight: 600,
          ),
        ),
        Expanded(
          child: MyText.bodyMedium(
            subTitle,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  buildDataRows(String outLets, String price, dynamic stock, String revenue) {
    return DataRow(
      cells: [
        DataCell(
          SizedBox(
            width: 300,
            child: MyText.bodySmall(
              outLets,
              fontWeight: 600,
            ),
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: MyText.bodySmall(
              price,
            ),
          ),
        ),
        DataCell(
          MyProgressBar(
            width: 300,
            height: 4,
            inactiveColor: contentTheme.secondary.withAlpha(40),
            activeColor: contentTheme.primary,
            progress: stock,
          ),
        ),
        DataCell(
          SizedBox(
            width: 100,
            child: MyText.bodySmall(
              revenue,
            ),
          ),
        ),
      ],
    );
  }
}
