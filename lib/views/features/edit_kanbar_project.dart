import 'dart:io';

import 'package:barrani/app_constant.dart';
import 'package:barrani/constants.dart';
import 'package:barrani/controller/features/kanban_add_task_controller.dart';
import 'package:barrani/global_functions.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/extensions/date_time_extention.dart';
import 'package:barrani/helpers/extensions/string.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
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
import 'package:barrani/models/kanbanProject.dart';
import 'package:barrani/models/user.dart';
import 'package:barrani/views/layouts/layout.dart';
import 'package:barrani/widgets/appointment_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditKanbanProject extends ConsumerStatefulWidget {
  static const routeName = '/kanban/project/edit';
  const EditKanbanProject({Key? key}) : super(key: key);

  @override
  ConsumerState<EditKanbanProject> createState() => _EditKanbanProjectState();
}

class _EditKanbanProjectState extends ConsumerState<EditKanbanProject>
    with SingleTickerProviderStateMixin, UIMixin {
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  bool isSubmitting = false;
  bool isSubmitted = false;
  XFile? thumbNail;
  String title = '';
  String description = '';
  XFile? pickedImage;
  String imageUrl = "";
  String image = "";
  String projectId = "";
  Uint8List? webImage;

  String? validateDescription(String value) {
    if (value.isEmpty) {
      return 'Description is required';
    } else if (value.length > 300) {
      return 'Description must not be more than 300 characters';
    }
    return null;
  }

  Future handleUploadImage() async {
    ImagePicker picker = ImagePicker();
    await picker.pickImage(source: ImageSource.gallery).then((xFile) async {
      if (xFile != null) {
        setState(() {
          imageUrl = '';
          pickedImage = xFile;
        });
        List<int> data = await xFile.readAsBytes();
        String path = 'products';
        String? imgUrl = kIsWeb
            ? await FirebaseWebHelper.uploadFile(data, path)
            : await uploadImage(data, path);
        if (imgUrl != null) {
          setState(() {
            pickedImage = null;
            // imageUrl = imgUrl;
            image = imgUrl;
          });
        }
      }
    });
  }

  // Get the values from the form
  GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController _projectName = TextEditingController();
  final TextEditingController _description = TextEditingController();

  bool loading = false;

  Future<void> submitToFirestore() async {
    setState(() {
      loading = true;
    });
    await FirebaseWebHelper.updateProject(projectId, title, description, image);
    setState(() {
      loading = false;
    });

    // Navigator.popAndPushNamed(context, '/kanban');
    showMessage(
      context: context,
      message: 'Project created sussessfully!',
      backgroundColor: contentTheme.success,
    );
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
// get parameters
    final Map<String, KanbanProject> args = ModalRoute.of(context)!
        .settings
        .arguments as Map<String, KanbanProject>;

    setState(() {
      imageUrl =
          args['project']!.thumbnail != null ? args['project']!.thumbnail! : "";
      projectId = args['project']!.id!;
      title = title.isEmpty ? args['project']!.projectName : title;
      description =
          description.isEmpty ? args['project']!.description : description;
    });

    print(imageUrl);

    var currentUsersStream = ref.watch(kIsWeb
        ? FirebaseWebHelper.allUsersStreamProvider
        : allUsersStreamProvider);
    return Layout(
      child: Column(
        children: [
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyText.titleMedium(
                  args['project']!.projectName,
                  fontSize: 18,
                  fontWeight: 600,
                ),
                MyBreadcrumb(
                  children: [
                    MyBreadcrumbItem(name: Trans('kanban').tr),
                    MyBreadcrumbItem(
                      name: Trans('add_project').tr.capitalizeWords,
                      active: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
          MySpacing.height(flexSpacing * 1),
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
                                Trans("general").tr,
                                fontWeight: 600,
                              ),
                            ],
                          ),
                          MySpacing.height(flexSpacing),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  MySpacing.width(20),
                                  if (imageUrl != "" &&
                                      pickedImage == null &&
                                      image == "")
                                    Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Image.network(imageUrl, width: 150),
                                        Positioned(
                                            top: 0,
                                            right: 0,
                                            child: InkWell(
                                              onTap: () {
                                                handleUploadImage();
                                              },
                                              child: Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                ),
                                                child: Icon(
                                                  Icons.edit,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ))
                                      ],
                                    )
                                  else
                                    MyButton.outlined(
                                      onPressed: () async {
                                        if (pickedImage != null) return;
                                        await handleUploadImage();
                                      },
                                      borderColor:
                                          imageUrl != "" || pickedImage != null
                                              ? Colors.transparent
                                              : contentTheme.secondary,
                                      padding:
                                          imageUrl != "" || pickedImage != null
                                              ? MySpacing.zero
                                              : MySpacing.xy(16, 16),
                                      child: image != "" && pickedImage == null
                                          ? Stack(
                                              alignment: Alignment.topRight,
                                              children: [
                                                Image.network(image,
                                                    width: 150),
                                                Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: InkWell(
                                                      onTap: () {
                                                        handleUploadImage();
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.black,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(50),
                                                        ),
                                                        child: Icon(
                                                          Icons.edit,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ))
                                              ],
                                            )
                                          : pickedImage != null
                                              ? Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    kIsWeb
                                                        ? Image.network(
                                                            pickedImage?.path ??
                                                                "",
                                                            width: 150,
                                                          )
                                                        : Image.file(
                                                            File(pickedImage
                                                                    ?.path ??
                                                                ""),
                                                            width: 150,
                                                          ),
                                                    SizedBox(
                                                      height: 20,
                                                      width: 20,
                                                      child:
                                                          CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              : MyText.labelMedium(
                                                  'Select Thumbnail',
                                                  fontWeight: 600,
                                                ),
                                    )
                                ],
                              ),
                              MySpacing.height(16),
                              MyFlexItem(
                                sizes: "lg-6",
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText.labelMedium(
                                      Trans("Project Name").tr.capitalizeWords,
                                    ),
                                    MySpacing.height(8),
                                    TextFormField(
                                      initialValue:
                                          args['project']!.projectName != null
                                              ? args['project']!.projectName
                                              : "",
                                      onChanged: (value) {
                                        setState(() {
                                          title = value;
                                        });
                                      },
                                      keyboardType: TextInputType.name,
                                      decoration: InputDecoration(
                                        hintText: "eg: kanban",
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
                                  ],
                                ),
                              ),
                              MySpacing.height(25),
                              MyText.labelMedium(
                                Trans("Description").tr,
                              ),
                              MySpacing.height(8),
                              TextFormField(
                                initialValue: args['project']!.description,
                                onChanged: (value) {
                                  setState(() {
                                    description = value;
                                  });
                                },
                                keyboardType: TextInputType.multiline,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: "kanban is.....",
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
                              MySpacing.height(20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  MyButton.text(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    padding: MySpacing.xy(20, 16),
                                    splashColor:
                                        contentTheme.secondary.withOpacity(0.1),
                                    child: MyText.bodySmall(
                                      Trans('cancel').tr,
                                    ),
                                  ),
                                  MySpacing.width(12),
                                  MyButton(
                                    onPressed: () async {
                                      try {
                                        await submitToFirestore();
                                        // Optionally show a success message to the user
                                        // replace with your UI logic
                                      } catch (e) {
                                        // Handle any errors

                                        // replace with your UI logic
                                        return;
                                      }
                                    },
                                    elevation: 0,
                                    padding: MySpacing.xy(20, 16),
                                    backgroundColor: contentTheme.primary,
                                    borderRadiusAll:
                                        AppStyle.buttonRadius.medium,
                                    child: Row(
                                      children: [
                                        loading
                                            ? SizedBox(
                                                height: 14,
                                                width: 14,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: theme
                                                      .colorScheme.onPrimary,
                                                  strokeWidth: 1.2,
                                                ),
                                              )
                                            : Container(),
                                        if (loading) MySpacing.width(16),
                                        MyText.bodySmall(
                                          Trans('save').tr,
                                          color: contentTheme.onPrimary,
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
