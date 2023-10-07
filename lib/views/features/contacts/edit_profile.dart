// Conditional import
import 'dart:io';

import 'package:barrani/controller/features/contact/edit_profile_controller.dart';
import 'package:barrani/global_functions.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/theme/app_style.dart';

import 'package:barrani/helpers/theme/theme_provider.dart';
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
import 'package:barrani/image_picker_platform.dart';
import 'package:barrani/images.dart';
import 'package:barrani/views/layouts/layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfile extends ConsumerStatefulWidget {
  static const routeName = "/contacts/edit-profile";
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends ConsumerState<EditProfile>
    with SingleTickerProviderStateMixin, UIMixin {
  late EditProfileController controller;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  ImagePickerPlatform picker = ImagePickerPlatform.instance;
  bool loading = false;
  XFile? pickedMainImage;
  String mainImageUrl = '';

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
            pickedMainImage = null;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    controller = Get.put(EditProfileController());
    if (userData != null) {
      mainImageUrl = userData?.photoUrl ?? "";
      firstNameController.text = userData?.names ?? "";
      lastNameController.text = userData?.names ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themesProvider);
    return Layout(
      child: GetBuilder(
        init: controller,
        builder: (controller) {
          return Column(
            children: [
              Padding(
                padding: MySpacing.x(flexSpacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.titleMedium(
                      "Edit Profile",
                      fontWeight: 600,
                    ),
                    MyBreadcrumb(
                      children: [
                        MyBreadcrumbItem(name: "Contact"),
                        MyBreadcrumbItem(name: "Edit Profile", active: true),
                      ],
                    ),
                  ],
                ),
              ),
              MySpacing.height(flexSpacing),
              Padding(
                padding: MySpacing.x(flexSpacing / 2),
                child: MyFlex(
                  children: [
                    MyFlexItem(
                      sizes: "lg-6",
                      child: MyCard(
                        shadow: MyShadow(elevation: 0.5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () async {
                                if (pickedMainImage != null) return;
                                await handleUploadMainImage();
                              },
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  if (pickedMainImage != null)
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Padding(
                                        padding: MySpacing.x(20),
                                        child: Stack(
                                          children: [
                                            // Image container
                                            MyContainer.rounded(
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 54, 53, 53),
                                                width: 1.5,
                                              ),
                                              paddingAll: 4,
                                              child: MyContainer.rounded(
                                                paddingAll: 0,
                                                height: 150,
                                                clipBehavior:
                                                    Clip.antiAliasWithSaveLayer,
                                                child: kIsWeb
                                                    ? Image.network(
                                                        pickedMainImage!.path,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.file(
                                                        File(pickedMainImage!
                                                            .path),
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),
                                            // Camera icon
                                            Positioned(
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  40,
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  230,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors.black54,
                                                ),
                                                padding: EdgeInsets.all(6.0),
                                                child: Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else if (mainImageUrl != '')
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Padding(
                                        padding: MySpacing.x(20),
                                        child: Stack(
                                          children: [
                                            // Image container
                                            MyContainer.rounded(
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 54, 53, 53),
                                                width: 1.5,
                                              ),
                                              paddingAll: 4,
                                              child: MyContainer.rounded(
                                                  paddingAll: 0,
                                                  height: 150,
                                                  clipBehavior: Clip
                                                      .antiAliasWithSaveLayer,
                                                  child: Image.network(
                                                    mainImageUrl,
                                                    fit: BoxFit.cover,
                                                    height: 150,
                                                    width: 150,
                                                  )),
                                            ),
                                            // Camera icon
                                            Positioned(
                                              bottom: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  40,
                                              right: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  230,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors.black54,
                                                ),
                                                padding: EdgeInsets.all(6.0),
                                                child: Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (pickedMainImage == null &&
                                      userData!.photoUrl.isEmpty &&
                                      mainImageUrl == "")
                                    Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Padding(
                                        padding: MySpacing.x(20),
                                        child: Stack(
                                          children: [
                                            // Image container
                                            MyContainer.rounded(
                                              border: Border.all(
                                                color: Color.fromARGB(
                                                    255, 54, 53, 53),
                                                width: 1.5,
                                              ),
                                              paddingAll: 0,
                                              child: MyContainer.rounded(
                                                  paddingAll: 0,
                                                  height: 120,
                                                  clipBehavior: Clip
                                                      .antiAliasWithSaveLayer,
                                                  child: Image.asset(
                                                      Images.avatars[0],
                                                      fit: BoxFit.cover)),
                                            ),
                                            // Camera icon
                                            Positioned(
                                              bottom: 0,
                                              right: 0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  color: Colors.black54,
                                                ),
                                                padding: EdgeInsets.all(6.0),
                                                child: Icon(
                                                  Icons.camera_alt,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            MySpacing.height(20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildTextField(
                                    "Full Name",
                                    userData == null
                                        ? "Enter your Full Name"
                                        : "${userData?.names}",
                                    firstNameController),
                                MySpacing.height(20),
                                MyButton(
                                  onPressed: () async {
                                    if (pickedMainImage != null) return;
                                    setState(() {
                                      loading = true;
                                    });
                                    // Get values from controllers
                                    String firstName = firstNameController.text;
                                    String lastName = lastNameController.text;
                                    String? imageUrl = mainImageUrl == ""
                                        ? userData?.photoUrl
                                        : mainImageUrl;

                                    kIsWeb
                                        ? await FirebaseWebHelper.onSavePressed(
                                            userData?.userId,
                                            firstName,
                                            lastName,
                                            imageUrl,
                                          )
                                        : await onSavePressed(userData?.userId,
                                            firstName, lastName, imageUrl);
                                    setState(() {
                                      loading = false;
                                    });
                                    showMessage(
                                      context: context,
                                      message: 'Profile updated sussessfully!',
                                      backgroundColor: contentTheme.success,
                                    );
                                    setState(() {});
                                  },
                                  elevation: 0,
                                  padding: MySpacing.xy(20, 16),
                                  backgroundColor: contentTheme.primary,
                                  borderRadiusAll: AppStyle.buttonRadius.medium,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      loading
                                          ? SizedBox(
                                              height: 14,
                                              width: 14,
                                              child: CircularProgressIndicator(
                                                color:
                                                    theme.colorScheme.onPrimary,
                                                strokeWidth: 1.2,
                                              ),
                                            )
                                          : Container(),
                                      if (loading) MySpacing.width(16),
                                      MyText.bodySmall(
                                        'Save',
                                        color: contentTheme.onPrimary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildTextField(
      String fieldTitle, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(
          fieldTitle,
        ),
        MySpacing.height(8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: MyTextStyle.bodySmall(xMuted: true),
            border: outlineInputBorder,
            contentPadding: MySpacing.all(16),
            isCollapsed: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
        ),
      ],
    );
  }
}

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');

    return newValue.copyWith(
      text: text.isNotEmpty ? text : '',
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
