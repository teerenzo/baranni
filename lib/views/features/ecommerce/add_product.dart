import 'dart:io';

import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/firebase/product_provider.dart';
import 'package:barrani/helpers/firebase/product_provider_web_helper.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/helpers/widgets/my_dotted_line.dart';
import 'package:barrani/helpers/widgets/my_list_extension.dart';
import 'package:barrani/images.dart';
import 'package:barrani/models/category.dart';
import 'package:barrani/models/group.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/instance_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:barrani/controller/ecommerce/add_product_controller.dart';
import 'package:barrani/helpers/extensions/string.dart';
import 'package:barrani/helpers/theme/app_style.dart';
import 'package:barrani/helpers/theme/app_theme.dart';
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
import 'package:barrani/helpers/widgets/my_text_style.dart';
import 'package:barrani/helpers/widgets/responsive.dart';
import 'package:barrani/views/layouts/layout.dart';

class AddProduct extends ConsumerStatefulWidget {
  const AddProduct({Key? key}) : super(key: key);
  static const String routeName = "/ecommerce/add_product";

  @override
  ConsumerState<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends ConsumerState<AddProduct>
    with SingleTickerProviderStateMixin, UIMixin {
  late AddProductController controller;
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController discountPercentage = TextEditingController();
  TextEditingController discountPrice = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController stock = TextEditingController();
  CategoryModal? category;
  GroupModal? group;
  List<XFile> pickedImages = [];
  XFile? pickedMainImage;
  List<String> imgUrls = [];
  String mainImageUrl = '';
  bool featured = false;
  bool isLoading = false;

  Future handleImageUpload() async {
    ImagePicker picker = ImagePicker();
    await picker.pickMultiImage().then((xFiles) async {
      setState(() {
        pickedImages.addAll(xFiles);
      });
      pickedImages.forEach((element) async {
        List<int> data = await element.readAsBytes();
        String path = 'products';
        String? imgUrl = kIsWeb
            ? await FirebaseWebHelper.uploadFile(data, path)
            : await uploadImage(data, path);

        if (imgUrl != null) {
          imgUrls.add(imgUrl);
        }
        setState(() {
          pickedImages.remove(element);
        });
      });
    });
  }

  Future handleUploadMainImage() async {
    ImagePicker picker = ImagePicker();
    await picker.pickImage(source: ImageSource.gallery).then((xFile) async {
      if (xFile != null) {
        setState(() {
          mainImageUrl = '';
          pickedMainImage = xFile;
        });
        List<int> data = await xFile.readAsBytes();
        String path = 'products';
        String? imgUrl = kIsWeb
            ? await FirebaseWebHelper.uploadFile(data, path)
            : await uploadImage(data, path);
        if (imgUrl != null) {
          setState(() {
            mainImageUrl = imgUrl;
          });
        }
      }
    });
  }

  Future handleAddProduct() async {
    Map<String, dynamic> newProduct = {
      'name': name.text,
      'main_image_url': mainImageUrl,
      'category_id': category?.id,
      'group': group?.id,
      'images': imgUrls,
      'productFeatures': [],
      'price': double.parse(price.text),
      'discountPercentage': double.parse(discountPercentage.text),
      'discountPrice': double.parse(discountPrice.text),
      'ratings': 0,
      'stock': int.parse(stock.text),
      'points': 0,
      'description': description.text,
      'createdDate': DateTime.now(),
      'featured': featured,
    };
    setState(() {
      isLoading = true;
    });
    if (kIsWeb) {
      await FirebaseWebHelper.addProduct(newProduct).then((value) {
        setState(() {
          isLoading = false;
        });
        NavigatorHelper.pushNamed('/ecommerce/products');
      });
    } else {
      await addProduct(newProduct).then((value) {
        setState(() {
          isLoading = false;
        });
        NavigatorHelper.pushNamed('/ecommerce/products');
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    controller = Get.put(AddProductController());
  }

  @override
  Widget build(BuildContext context) {
    var categories = ref.watch(kIsWeb
        ? allCategoriesStreamProviderWebHelper
        : allCategoriesStreamProvider);
    var groups = ref.watch(
        kIsWeb ? allGroupsStreamProviderWebHelper : allGroupsStreamProvider);
    return Layout(
      child: Column(
        children: [
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium(
                  "add_product".tr().capitalizeWords,
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: 'ecommerce'.tr()),
                    MyBreadcrumbItem(
                      name: 'add_product'.tr().capitalizeWords,
                      active: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          MySpacing.height(flexSpacing * 3),
          Padding(
            padding: MySpacing.x(flexSpacing / 2),
            child: MyFlex(
              children: [
                MyFlexItem(
                  sizes: "lg-8",
                  child: MyCard(
                    shadow: MyShadow(elevation: 0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(
                                LucideIcons.server,
                                size: 16,
                              ),
                              MySpacing.width(12),
                              MyText.titleMedium(
                                "general".tr(),
                                fontWeight: 600,
                              ),
                            ],
                          ),
                          MySpacing.height(flexSpacing),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: MyFlex(
                                  wrapAlignment: WrapAlignment.center,
                                  wrapCrossAlignment: WrapCrossAlignment.center,
                                  children: [
                                    MyFlexItem(
                                      child: MyCard(
                                        shadow: MyShadow(elevation: 0.5),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            if (imgUrls.isEmpty &&
                                                pickedImages.isEmpty)
                                              InkWell(
                                                onTap: () async {
                                                  await handleImageUpload();
                                                },
                                                child: MyDottedLine(
                                                  strokeWidth: 0.2,
                                                  color:
                                                      contentTheme.onBackground,
                                                  corner:
                                                      const MyDottedLineCorner(
                                                    leftBottomCorner: 2,
                                                    leftTopCorner: 2,
                                                    rightBottomCorner: 2,
                                                    rightTopCorner: 2,
                                                  ),
                                                  child: Center(
                                                    child: Padding(
                                                      padding:
                                                          MySpacing.all(12),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          Image.asset(
                                                            Images
                                                                .fileManager[1],
                                                            height: 200,
                                                          ),
                                                          MyContainer(
                                                            alignment: Alignment
                                                                .center,
                                                            paddingAll: 0,
                                                            child: MyText
                                                                .titleMedium(
                                                              "Drop product images here or click to upload.",
                                                              fontWeight: 600,
                                                              muted: true,
                                                              fontSize: 18,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (pickedImages.isNotEmpty ||
                                                imgUrls.isNotEmpty) ...[
                                              MySpacing.height(16),
                                              SizedBox(
                                                width: double.infinity,
                                                child: Wrap(
                                                  runSpacing: 16,
                                                  spacing: 16,
                                                  children: [
                                                    ...imgUrls
                                                        .map(
                                                          (e) => MyContainer(
                                                            color: contentTheme
                                                                .primary
                                                                .withAlpha(80),
                                                            paddingAll: 0,
                                                            child: Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                SizedBox(
                                                                  height: 100,
                                                                  width: 100,
                                                                  child: Image
                                                                      .network(
                                                                    e,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ),
                                                                Positioned(
                                                                  top: 0,
                                                                  right: 0,
                                                                  child:
                                                                      IconButton(
                                                                    onPressed:
                                                                        () {
                                                                      deleteImage(
                                                                              e)
                                                                          .then(
                                                                              (value) {
                                                                        setState(
                                                                            () {
                                                                          imgUrls
                                                                              .remove(e);
                                                                        });
                                                                      });
                                                                    },
                                                                    icon:
                                                                        const Icon(
                                                                      Icons
                                                                          .close_outlined,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                    ...pickedImages
                                                        .mapIndexed(
                                                          (index, file) =>
                                                              MyContainer(
                                                            color: contentTheme
                                                                .primary
                                                                .withAlpha(80),
                                                            paddingAll: 0,
                                                            child: Stack(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              children: [
                                                                SizedBox(
                                                                  height: 100,
                                                                  width: 100,
                                                                  child: kIsWeb
                                                                      ? Image
                                                                          .network(
                                                                          file.path,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        )
                                                                      : Image
                                                                          .file(
                                                                          File(file
                                                                              .path),
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                ),
                                                                SizedBox(
                                                                  height: 20,
                                                                  width: 20,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                        .toList(),
                                                    MyContainer(
                                                      color:
                                                          contentTheme.primary,
                                                      height: 100,
                                                      width: 100,
                                                      paddingAll: 0,
                                                      child: IconButton(
                                                        onPressed: () async {
                                                          await handleImageUpload();
                                                        },
                                                        icon: const Icon(
                                                          Icons
                                                              .add_photo_alternate_rounded,
                                                          color: Colors.white,
                                                          size: 60,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              MySpacing.height(25),
                              MyFlex(contentPadding: false, children: [
                                MyFlexItem(
                                  sizes: "lg-6",
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyText.labelMedium(
                                        "product main image"
                                            .tr()
                                            .capitalizeWords,
                                      ),
                                      MySpacing.height(8),
                                      InkWell(
                                        onTap: () async {
                                          await handleUploadMainImage();
                                        },
                                        child: MyContainer(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(4)),
                                          bordered: true,
                                          border: Border.all(
                                              width: 1,
                                              strokeAlign: 0,
                                              color: theme
                                                  .colorScheme.onBackground
                                                  .withAlpha(80)),
                                          padding: MySpacing.xy(12, 12),
                                          child: Row(
                                            children: [
                                              MyText.bodySmall("Upload File"),
                                              MySpacing.width(12),
                                              const Icon(
                                                LucideIcons.upload,
                                                size: 16,
                                              ),
                                              MySpacing.width(12),
                                              if (pickedMainImage != null)
                                                MyText.bodySmall(
                                                  pickedMainImage!.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                              MySpacing.height(25),
                              MyFlex(
                                contentPadding: false,
                                children: [
                                  MyFlexItem(
                                    sizes: "lg-6",
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText.labelMedium(
                                          "product_name".tr().capitalizeWords,
                                        ),
                                        MySpacing.height(8),
                                        TextFormField(
                                          validator: controller.basicValidator
                                              .getValidation('product_name'),
                                          controller: name,
                                          readOnly: isLoading,
                                          keyboardType: TextInputType.name,
                                          decoration: InputDecoration(
                                            hintText: "eg: Tomatoes",
                                            hintStyle: MyTextStyle.bodySmall(
                                                xMuted: true),
                                            border: outlineInputBorder,
                                            enabledBorder: outlineInputBorder,
                                            focusedBorder: focusedInputBorder,
                                            contentPadding: MySpacing.all(16),
                                            isCollapsed: true,
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.never,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  MyFlexItem(
                                    sizes: 'lg-6 md-12',
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText.labelMedium(
                                          "price".tr(),
                                        ),
                                        MySpacing.height(8),
                                        TextFormField(
                                          validator: controller.basicValidator
                                              .getValidation('price'),
                                          controller: price,
                                          readOnly: isLoading,
                                          keyboardType: TextInputType.multiline,
                                          decoration: InputDecoration(
                                            hintText: "99.99",
                                            hintStyle: MyTextStyle.bodySmall(
                                                xMuted: true),
                                            border: outlineInputBorder,
                                            enabledBorder: outlineInputBorder,
                                            focusedBorder: focusedInputBorder,
                                            prefixIcon: MyContainer.none(
                                              margin: MySpacing.right(12),
                                              alignment: Alignment.center,
                                              color: contentTheme.primary
                                                  .withAlpha(40),
                                              child: Icon(
                                                LucideIcons.circleDollarSign,
                                                color: contentTheme.primary,
                                              ),
                                            ),
                                            prefixIconConstraints:
                                                const BoxConstraints(
                                              maxHeight: 39,
                                              minWidth: 50,
                                              maxWidth: 50,
                                            ),
                                            contentPadding: MySpacing.all(12),
                                            isCollapsed: true,
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.never,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              MySpacing.height(25),
                              MyFlex(
                                contentPadding: false,
                                children: [
                                  MyFlexItem(
                                    sizes: "lg-6",
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText.labelMedium(
                                          "discount_percentage"
                                              .tr()
                                              .capitalizeWords,
                                        ),
                                        MySpacing.height(8),
                                        TextFormField(
                                          validator: controller.basicValidator
                                              .getValidation('product_name'),
                                          controller: discountPercentage,
                                          readOnly: isLoading,
                                          keyboardType: TextInputType.name,
                                          decoration: InputDecoration(
                                            hintText: "eg: 3%",
                                            hintStyle: MyTextStyle.bodySmall(
                                                xMuted: true),
                                            border: outlineInputBorder,
                                            enabledBorder: outlineInputBorder,
                                            focusedBorder: focusedInputBorder,
                                            contentPadding: MySpacing.all(16),
                                            isCollapsed: true,
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.never,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  MyFlexItem(
                                      sizes: "lg-6",
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MyText.labelMedium(
                                            "discount_price"
                                                .tr()
                                                .capitalizeWords,
                                          ),
                                          MySpacing.height(8),
                                          TextFormField(
                                            validator: controller.basicValidator
                                                .getValidation('shop_name'),
                                            controller: discountPrice,
                                            readOnly: isLoading,
                                            keyboardType: TextInputType.name,
                                            decoration: InputDecoration(
                                              hintText: "3.43",
                                              hintStyle: MyTextStyle.bodySmall(
                                                  xMuted: true),
                                              prefixIcon: MyContainer.none(
                                                margin: MySpacing.right(12),
                                                alignment: Alignment.center,
                                                color: contentTheme.primary
                                                    .withAlpha(40),
                                                child: Icon(
                                                  LucideIcons.circleDollarSign,
                                                  color: contentTheme.primary,
                                                ),
                                              ),
                                              prefixIconConstraints:
                                                  const BoxConstraints(
                                                maxHeight: 39,
                                                minWidth: 50,
                                                maxWidth: 50,
                                              ),
                                              border: outlineInputBorder,
                                              enabledBorder: outlineInputBorder,
                                              focusedBorder: focusedInputBorder,
                                              contentPadding: MySpacing.all(16),
                                              isCollapsed: true,
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.never,
                                            ),
                                          ),
                                        ],
                                      ))
                                ],
                              ),
                              MySpacing.height(25),
                              MyText.labelMedium(
                                "description".tr(),
                              ),
                              MySpacing.height(8),
                              TextFormField(
                                validator: controller.basicValidator
                                    .getValidation('description'),
                                controller: description,
                                readOnly: isLoading,
                                keyboardType: TextInputType.multiline,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: "It's contains blah blah things",
                                  hintStyle:
                                      MyTextStyle.bodySmall(xMuted: true),
                                  border: outlineInputBorder,
                                  enabledBorder: outlineInputBorder,
                                  focusedBorder: focusedInputBorder,
                                  contentPadding: MySpacing.all(16),
                                  isCollapsed: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                ),
                              ),
                              MySpacing.height(25),
                              MyFlex(
                                contentPadding: false,
                                children: [
                                  MyFlexItem(
                                    sizes: 'lg-6 md-12',
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MyText.labelMedium(
                                          "category".tr(),
                                        ),
                                        MySpacing.height(8),
                                        categories
                                            .whenData(
                                          (value) => PopupMenuButton(
                                            onSelected: (value) {
                                              setState(() {
                                                category = value;
                                              });
                                            },
                                            itemBuilder:
                                                (BuildContext context) {
                                              return value.map((category) {
                                                return PopupMenuItem(
                                                  value: category,
                                                  height: 32,
                                                  child: MyText.bodySmall(
                                                    category.name,
                                                    color: theme.colorScheme
                                                        .onBackground,
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  MyText.labelMedium(
                                                    category?.name ??
                                                        'Select Category',
                                                    color: theme.colorScheme
                                                        .onBackground,
                                                  ),
                                                  Icon(
                                                    Icons.expand_more_outlined,
                                                    size: 22,
                                                    color: theme.colorScheme
                                                        .onBackground,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                            .when(error: (error, stack) {
                                          print(error);
                                          return Container();
                                        }, loading: () {
                                          return Container();
                                        }, data: (data) {
                                          return data;
                                        }),
                                      ],
                                    ),
                                  ),
                                  MyFlexItem(
                                      sizes: 'lg-6 md-12',
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MyText.labelMedium(
                                            "group".tr(),
                                          ),
                                          MySpacing.height(8),
                                          groups
                                              .whenData(
                                            (value) => PopupMenuButton(
                                              onSelected: (value) {
                                                setState(() {
                                                  group = value;
                                                });
                                              },
                                              itemBuilder:
                                                  (BuildContext context) {
                                                return value.map((group) {
                                                  return PopupMenuItem(
                                                    value: group,
                                                    height: 32,
                                                    child: MyText.bodySmall(
                                                      group.name,
                                                      color: theme.colorScheme
                                                          .onBackground,
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    MyText.labelMedium(
                                                      group?.name ??
                                                          'Select Group',
                                                      color: theme.colorScheme
                                                          .onBackground,
                                                    ),
                                                    Icon(
                                                      Icons
                                                          .expand_more_outlined,
                                                      size: 22,
                                                      color: theme.colorScheme
                                                          .onBackground,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                              .when(error: (error, stack) {
                                            return Container();
                                          }, loading: () {
                                            return Container();
                                          }, data: (data) {
                                            return data;
                                          }),
                                        ],
                                      )),
                                ],
                              ),
                              MySpacing.height(25),
                              MyFlex(
                                  contentPadding: false,
                                  wrapCrossAlignment: WrapCrossAlignment.center,
                                  children: [
                                    MyFlexItem(
                                      sizes: 'lg-6 md-12',
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          MyText.labelMedium(
                                            "stock".tr(),
                                          ),
                                          MySpacing.height(8),
                                          TextFormField(
                                            validator: controller.basicValidator
                                                .getValidation('price'),
                                            controller: stock,
                                            readOnly: isLoading,
                                            keyboardType:
                                                TextInputType.multiline,
                                            decoration: InputDecoration(
                                              hintText: "99",
                                              hintStyle: MyTextStyle.bodySmall(
                                                  xMuted: true),
                                              border: outlineInputBorder,
                                              enabledBorder: outlineInputBorder,
                                              focusedBorder: focusedInputBorder,
                                              contentPadding: MySpacing.all(12),
                                              isCollapsed: true,
                                              floatingLabelBehavior:
                                                  FloatingLabelBehavior.never,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    MyFlexItem(
                                      sizes: 'lg-6 md-12',
                                      child: SwitchListTile(
                                          activeColor: contentTheme.primary,
                                          value: featured,
                                          onChanged: (value) {
                                            setState(() {
                                              featured = value;
                                            });
                                          },
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          visualDensity: getCompactDensity,
                                          contentPadding: MySpacing.zero,
                                          title: MyText.bodyMedium(
                                              "Featured".tr())),
                                    ),
                                  ]),
                              MySpacing.height(20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  MyButton.text(
                                    onPressed: () {
                                      if (isLoading) {
                                        return;
                                      }
                                      NavigatorHelper.pushNamed(
                                          '/ecommerce/products');
                                    },
                                    padding: MySpacing.xy(20, 16),
                                    splashColor:
                                        contentTheme.secondary.withOpacity(0.1),
                                    child: MyText.bodySmall(
                                      'cancel'.tr(),
                                    ),
                                  ),
                                  MySpacing.width(12),
                                  MyButton(
                                    onPressed: () {
                                      if (isLoading) {
                                        return;
                                      }
                                      handleAddProduct();
                                    },
                                    elevation: 0,
                                    padding: MySpacing.xy(20, 16),
                                    backgroundColor: contentTheme.primary,
                                    borderRadiusAll:
                                        AppStyle.buttonRadius.medium,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        MyText.bodySmall(
                                          'save'.tr(),
                                          color: contentTheme.onPrimary,
                                        ),
                                        if (isLoading) SizedBox(width: 10),
                                        if (isLoading)
                                          SizedBox(
                                            height: 10,
                                            width: 10,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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
