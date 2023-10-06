import 'package:barrani/helpers/extensions/string.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/theme/app_style.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb_item.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_card.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_flex.dart';
import 'package:barrani/helpers/widgets/my_flex_item.dart';
import 'package:barrani/helpers/widgets/my_responsiv.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/responsive.dart';
import 'package:barrani/images.dart';
import 'package:barrani/views/features/kanban_tasks.dart';
import 'package:barrani/views/layouts/layout.dart';
import 'package:barrani/widgets/project_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class KanBanPage extends StatefulWidget {
  static const routeName = '/kanban';
  const KanBanPage({Key? key}) : super(key: key);

  @override
  State<KanBanPage> createState() => _KanBanPageState();
}

class _KanBanPageState extends State<KanBanPage>
    with SingleTickerProviderStateMixin, UIMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Consumer(
        builder: (context, ref, child) {
          var projects = ref.watch(FirebaseWebHelper.kanbanProjectsProvider);
          return MyResponsive(builder: (_, __, type) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: MySpacing.x(flexSpacing),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      MyText.titleMedium(
                        "KanBan",
                        fontSize: 18,
                        fontWeight: 600,
                      ),
                      MyBreadcrumb(
                        children: [
                          MyBreadcrumbItem(name: 'Apps'),
                          MyBreadcrumbItem(name: 'KanBan', active: true),
                        ],
                      ),
                    ],
                  ),
                ),
                MySpacing.height(flexSpacing),
                Padding(
                  padding: MySpacing.x(flexSpacing),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (kIsWeb)
                        MyButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushNamed('/kanban/project/add');
                            // showDialog(
                            //   context: context,
                            //   builder: (BuildContext context) {
                            //     return Builder(
                            //       builder: (BuildContext context) {
                            //         return AlertDialog(
                            //           title: Text('Add Project'),
                            //           content: ProjectDialog(
                            //             isMobile: type.isMobile,
                            //           ),
                            //         );
                            //       },
                            //     );
                            //   },
                            // );
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
                                'create_project'.tr().capitalizeWords,
                                color: contentTheme.onPrimary,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                MySpacing.height(flexSpacing),
                Padding(
                  padding: MySpacing.x(flexSpacing / 2),
                  child: MyFlex(
                      wrapAlignment: WrapAlignment.start,
                      wrapCrossAlignment: WrapCrossAlignment.start,
                      children: projects.when(data: (project) {
                        return project.map((e) {
                          return MyFlexItem(
                            sizes: "xl-3 md-3 sm-3",
                            child: InkWell(
                              onTap: () {
                                Navigator.pushNamed(context, '/kanban/tasks',
                                    arguments: {'project': e});
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  MyCard(
                                    paddingAll: 0,
                                    borderRadiusAll: 5,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: (e.thumbnail == null ||
                                            e.thumbnail!.isEmpty)
                                        ? Image.asset(
                                            Images.landscapeImages[2],
                                            fit: BoxFit.cover,
                                            height: 150,
                                            width: double.infinity,
                                          )
                                        : Image.network(e.thumbnail!,
                                            fit: BoxFit.cover,
                                            height: 150,
                                            width: double.infinity),
                                  ),
                                  MyContainer(
                                    color: contentTheme.dark.withAlpha(150),
                                    height: 150,
                                    borderRadiusAll: 5,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 150,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  MyText.titleMedium(
                                                    e.projectName,
                                                    fontWeight: 600,
                                                    maxLines: 1,
                                                    color: contentTheme.light,
                                                  ),
                                                  MySpacing.height(8),
                                                  MyText.bodySmall(
                                                    e.description,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    color: contentTheme.light,
                                                    fontWeight: 600,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Spacer(),
                                            IconButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pushNamed(
                                                          '/kanban/project/edit',
                                                          arguments: {
                                                        'project': e
                                                      });
                                                },
                                                icon: Icon(
                                                  Icons.edit_document,
                                                  color: contentTheme.light,
                                                  size: 18,
                                                )),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList();
                      }, error: (e, stack) {
                        return [
                          MyFlexItem(
                            child: Text(e.toString()),
                          )
                        ];
                      }, loading: () {
                        return [
                          MyFlexItem(
                              child: Center(
                            child: CircularProgressIndicator(),
                          ))
                        ];
                      })),
                ),
              ],
            );
          });
        },
      ),
    );
  }
}
