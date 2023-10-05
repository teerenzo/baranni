import 'dart:math';

import 'package:appflowy_board/appflowy_board.dart';
import 'package:barrani/controller/features/kanban_controller.dart';
import 'package:barrani/helpers/extensions/extensions.dart';
import 'package:barrani/helpers/theme/app_style.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:barrani/helpers/theme/app_theme.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb_item.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/responsive.dart';
import 'package:barrani/views/layouts/layout.dart';

class KanBanPage extends ConsumerStatefulWidget {
  static const routeName = '/kanban';

  const KanBanPage({Key? key}) : super(key: key);

  @override
  ConsumerState<KanBanPage> createState() => _KanBanPageState();
}

class _KanBanPageState extends ConsumerState<KanBanPage>
    with SingleTickerProviderStateMixin, UIMixin {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Consumer(
        // init: controller,
        builder: (context, watch, child) {
          final controller = ref.watch(kanbanControllerProvider);
          controller.boardController = AppFlowyBoardScrollController();

          controller.initializeBoardData();

          return Column(
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
                        onPressed: controller.goToCreateKanbanTask,
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
                              'create_task'.tr().capitalizeWords,
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
                child: PrimaryScrollController(
                  controller: ScrollController(),
                  child: AppFlowyBoard(
                    config: AppFlowyBoardConfig(
                      stretchGroupHeight: false,
                      groupBackgroundColor: contentTheme.primary.withAlpha(20),
                    ),
                    controller: controller.boardData,
                    cardBuilder: (context, group, groupItem) {
                      // int index = statuses.indexOf(group.id);
                      return AppFlowyGroupCard(
                        key: ValueKey(group.id),
                        decoration:
                            BoxDecoration(color: theme.colorScheme.background),
                        child: buildCard(groupItem),
                      );
                    },
                    boardScrollController: controller.boardController,
                    footerBuilder: (context, columnData) {
                      return MySpacing.height(16);
                    },
                    headerBuilder: (context, columnData) {
                      return SizedBox(
                        height: 40,
                        child: ListView.builder(
                          controller: _controller,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return AppFlowyGroupHeader(
                              title: MyText.bodyMedium(
                                columnData.headerData.groupName,
                                fontSize: 16,
                                fontWeight: 600,
                                muted: true,
                              ),
                              margin: MySpacing.x(16),
                              height: 40,
                            );
                          },
                        ),
                      );
                    },
                    groupConstraints: const BoxConstraints.tightFor(
                      width: 400,
                    ),
                  ),
                ),
              ),
              if (!kIsWeb) // Only show this FAB if it's not on web
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FloatingActionButton(
                    onPressed: controller.goToCreateKanbanTask,
                    backgroundColor: contentTheme.primary,
                    child: Icon(
                      LucideIcons.plus,
                      color: Color(0xffffffff),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget buildCard(AppFlowyGroupItem item) {
    if (item is TextItem) {
      return Padding(
        padding: MySpacing.xy(12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyContainer(
                  color: item.color,
                  borderRadiusAll: 4,
                  padding: MySpacing.xy(8, 4),
                  child: MyText(
                    item.kanbanLevel ?? '',
                    fontSize: 12,
                    color: contentTheme.onPrimary,
                  ),
                ),
                MyText.bodyMedium(item.date ?? '', muted: true)
              ],
            ),
            MySpacing.height(12),
            MyText.bodyMedium(
              item.title ?? '',
            ),
            MySpacing.height(12),
            Row(
              children: [
                const Icon(
                  LucideIcons.luggage,
                  size: 16,
                ),
                MySpacing.width(8),
                MyText.bodyMedium(item.jobTypeName ?? '', muted: true),
                MySpacing.width(16),
                // const Icon(
                //   LucideIcons.messageSquare,
                //   size: 20,
                // ),
                MySpacing.width(8),
                // MyText.bodyMedium("${item.images} comments", muted: true),
                SizedBox(
                  width: 161,
                  height: 30,
                  child: SizedBox(
                    width: 161,
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: item.images?.asMap().entries.map((entry) {
                            final index = entry.key;
                            final imageUrl = entry.value;
                            final leftPosition = 18 + (20 * index).toDouble();
                            if (imageUrl == '') return Container();
                            return Positioned(
                              left: leftPosition,
                              child: MyContainer.rounded(
                                paddingAll: 2,
                                child: MyContainer.rounded(
                                  bordered: true,
                                  paddingAll: 0,
                                  child: Image.network(
                                    imageUrl,
                                    height: 28,
                                    width: 28,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          }).toList() ??
                          [],
                    ),
                  ),
                )
              ],
            ),
            MySpacing.height(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    MyContainer.rounded(
                      paddingAll: 0,
                      height: 32,
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      child: Image.network(item.image ?? ''),
                    ),
                    MySpacing.width(8),
                    MyText.bodyMedium(
                      item.name ?? '',
                    ),
                  ],
                ),
                MyContainer.none(
                  paddingAll: 8,
                  borderRadiusAll: 5,
                  child: PopupMenuButton(
                    offset: const Offset(-150, 15),
                    position: PopupMenuPosition.under,
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                          padding: MySpacing.xy(16, 8),
                          height: 10,
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.plusCircle,
                                size: 20,
                              ),
                              MySpacing.width(8),
                              MyText.bodySmall("Add People"),
                            ],
                          )),
                      PopupMenuItem(
                          padding: MySpacing.xy(16, 8),
                          height: 10,
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.edit,
                                size: 20,
                              ),
                              MySpacing.width(8),
                              MyText.bodySmall("Edit"),
                            ],
                          )),
                      PopupMenuItem(
                          padding: MySpacing.xy(16, 8),
                          height: 10,
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.trash,
                                size: 20,
                              ),
                              MySpacing.width(8),
                              MyText.bodySmall("Delete"),
                            ],
                          )),
                      PopupMenuItem(
                          padding: MySpacing.xy(16, 8),
                          height: 10,
                          child: Row(
                            children: [
                              const Icon(
                                LucideIcons.logOut,
                                size: 20,
                              ),
                              MySpacing.width(8),
                              MyText.bodySmall("Leave"),
                            ],
                          )),
                    ],
                    child: const Icon(
                      LucideIcons.moreVertical,
                      size: 18,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }

    if (item is RichTextItem) {
      return RichTextCard(item: item);
    }

    throw UnimplementedError();
  }
}

class RichTextCard extends StatefulWidget {
  final RichTextItem item;

  const RichTextCard({
    required this.item,
    Key? key,
  }) : super(key: key);

  @override
  State<RichTextCard> createState() => _RichTextCardState();
}

class _RichTextCardState extends State<RichTextCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.item.title,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}

class RichTextItem extends AppFlowyGroupItem {
  final String title;
  final String subtitle;

  RichTextItem({required this.title, required this.subtitle});

  @override
  String get id => title;
}
