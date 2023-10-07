import 'package:barrani/helpers/theme/admin_theme.dart';
import 'package:barrani/helpers/theme/theme_provider.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:flutter/material.dart';

import 'package:barrani/helpers/widgets/my_breadcrumb_item.dart';
import 'package:barrani/helpers/widgets/my_constant.dart';
import 'package:barrani/helpers/widgets/my_responsiv.dart';
import 'package:barrani/helpers/widgets/my_router.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyBreadcrumb extends ConsumerStatefulWidget {
  final List<MyBreadcrumbItem> children;
  final bool hideOnMobile;

  MyBreadcrumb({super.key, required this.children, this.hideOnMobile = true}) {
    if (MyConstant.constant.defaultBreadCrumbItem != null) {
      children.insert(0, MyConstant.constant.defaultBreadCrumbItem!);
    }
  }

  @override
  ConsumerState<MyBreadcrumb> createState() => _MyBreadcrumbState();
}

class _MyBreadcrumbState extends ConsumerState<MyBreadcrumb>
    with SingleTickerProviderStateMixin, UIMixin {
  @override
  Widget build(BuildContext context) {
    ref.watch(themesProvider);
    List<Widget> list = [];
    for (int i = 0; i < widget.children.length; i++) {
      var item = widget.children[i];
      if (item.active || item.route == null) {
        list.add(MyText.labelMedium(
          widget.children[i].name,
          fontWeight: 500,
          fontSize: 13,
          letterSpacing: 0,
          color: contentTheme.onBackground,
        ));
      } else {
        list.add(InkWell(
            onTap: () => {
                  if (item.route != null)
                    MyRouter.pushReplacementNamed(context, item.route!)
                },
            child: MyText.labelMedium(
              widget.children[i].name,
              fontWeight: 500,
              fontSize: 13,
              letterSpacing: 0,
              color: contentTheme.primary,
            )));
      }
      if (i < widget.children.length - 1) {
        list.add(MySpacing.width(10));
        list.add(MyText(">"));
        list.add(MySpacing.width(10));
      }
    }
    return MyResponsive(builder: (_, __, type) {
      return type.isMobile && widget.hideOnMobile
          ? SizedBox()
          : Row(mainAxisSize: MainAxisSize.min, children: list);
    });
  }
}
