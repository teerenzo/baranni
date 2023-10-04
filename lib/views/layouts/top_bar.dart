import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/firebase/auth.dart';
import 'package:barrani/helpers/localizations/language.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/helpers/services/web_auth_services.dart';
import 'package:barrani/helpers/storage/local_storage.dart';
import 'package:barrani/helpers/theme/app_notifier.dart';
import 'package:barrani/helpers/theme/app_style.dart';
import 'package:barrani/helpers/theme/app_theme.dart';
import 'package:barrani/helpers/theme/theme_customizer.dart';
import 'package:barrani/helpers/utils/my_shadow.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_card.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/images.dart';
import 'package:barrani/widgets/custom_pop_menu.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:one_context/one_context.dart';
import 'package:provider/provider.dart';
import 'notification_popUp.dart';

class TopBar extends StatefulWidget {
  const TopBar({
    super.key, // this.onMenuIconTap,
  });

  @override
  _TopBarState createState() => _TopBarState();
}

class _TopBarState extends State<TopBar>
    with SingleTickerProviderStateMixin, UIMixin {
  Function? languageHideFn;
  String status = '';

  @override
  Widget build(BuildContext context) {
    Widget buildNotification(String title, String description) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.labelLarge(
            title,
            color: Colors.white,
          ),
          MySpacing.height(4),
          MyText.bodySmall(description, color: Colors.white)
        ],
      );
    }

    // check if notification time is less done 2 minutes and not read and show snackbar

    if (notifications.isNotEmpty) {
      notifications.forEach((element) async {
        if (!element.isRead) {
          OneContext().showSnackBar(
            builder: (_) => SnackBar(
              behavior: SnackBarBehavior.fixed,
              backgroundColor: contentTheme.primary,
              content: buildNotification(element.title, element.body),
              action: SnackBarAction(
                label: '',
                onPressed: () {
                  OneContext().pushNamed('/notifications');
                },
              ),
            ),
          );
          await element.readyNotification();
        }
      });
    }
    return MyCard(
      shadow: MyShadow(position: MyShadowPosition.bottomRight, elevation: 0.5),
      height: 60,
      borderRadiusAll: 0,
      padding: MySpacing.x(24),
      color: topBarTheme.background.withAlpha(246),
      child: Row(
        children: [
          Row(
            children: [
              InkWell(
                splashColor: theme.colorScheme.onBackground,
                highlightColor: theme.colorScheme.onBackground,
                onTap: () {
                  ThemeCustomizer.toggleLeftBarCondensed();
                },
                child: Icon(
                  LucideIcons.menu,
                  color: topBarTheme.onBackground,
                ),
              ),
            ],
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    ThemeCustomizer.setTheme(
                        ThemeCustomizer.instance.theme == ThemeMode.dark
                            ? ThemeMode.light
                            : ThemeMode.dark);
                  },
                  child: Icon(
                    ThemeCustomizer.instance.theme == ThemeMode.dark
                        ? FeatherIcons.sun
                        : FeatherIcons.moon,
                    size: 18,
                    color: topBarTheme.onBackground,
                  ),
                ),
                MySpacing.width(12),
                CustomPopupMenu(
                  backdrop: true,
                  hideFn: (_) => languageHideFn = _,
                  onChange: (_) {},
                  offsetX: -36,
                  menu: Padding(
                    padding: MySpacing.xy(8, 8),
                    child: Center(
                      child: ClipRRect(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        borderRadius: BorderRadius.circular(2),
                        child: Image.asset(
                          "assets/lang/${ThemeCustomizer.instance.currentLanguage.locale.languageCode}.jpg",
                          width: 24,
                          height: 18,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  menuBuilder: (_) => buildLanguageSelector(),
                ),
                MySpacing.width(6),
                CustomPopupMenu(
                  backdrop: true,
                  onChange: (_) {},
                  offsetX: -120,
                  menu: Padding(
                    padding: MySpacing.xy(8, 8),
                    child: Center(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Icon(
                            FeatherIcons.bell,
                            size: 18,
                          ),
                          if (notifications
                              .where((element) => !element.isRead)
                              .isNotEmpty)
                            MyContainer.rounded(
                              width: 9,
                              height: 9,
                              color: contentTheme.danger,
                            ),
                        ],
                      ),
                    ),
                  ),
                  menuBuilder: (_) =>
                      NotificationPopUp(contentTheme: contentTheme),
                ),
                MySpacing.width(4),
                CustomPopupMenu(
                  backdrop: true,
                  onChange: (_) {},
                  offsetX: -60,
                  offsetY: 8,
                  menu: Padding(
                    padding: MySpacing.xy(8, 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        MyContainer.rounded(
                          paddingAll: 0,
                          child: userData?.photoUrl == ""
                              ? Image.asset(
                                  Images.avatars[0],
                                  height: 28,
                                  width: 28,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  userData?.photoUrl ?? "",
                                  height: 28,
                                  width: 28,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        MySpacing.width(8),
                        MyText.labelLarge(userData?.names ?? "")
                      ],
                    ),
                  ),
                  menuBuilder: (_) => userData != null && status == ''
                      ? buildAccountMenu()
                      : Container(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildLanguageSelector() {
    return MyContainer.bordered(
      padding: MySpacing.xy(8, 8),
      width: 125,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: Language.languages
            .map((language) => MyButton.text(
                  padding: MySpacing.xy(8, 4),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  splashColor: contentTheme.onBackground.withAlpha(20),
                  onPressed: () async {
                    languageHideFn?.call();
                    // Language.changeLanguage(language);
                    await Provider.of<AppNotifier>(context, listen: false)
                        .changeLanguage(language, notify: true);
                    ThemeCustomizer.notify();
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      ClipRRect(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          borderRadius: BorderRadius.circular(2),
                          child: Image.asset(
                            "assets/lang/${language.locale.languageCode}.jpg",
                            width: 18,
                            height: 14,
                            fit: BoxFit.cover,
                          )),
                      MySpacing.width(8),
                      MyText.labelMedium(language.languageName)
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget buildAccountMenu() {
    return MyContainer.bordered(
      paddingAll: 0,
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.xy(8, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyButton(
                  onPressed: () {
                    setState(() {
                      status = 'ok';
                    });
                    NavigatorHelper.pushNamed('/contacts/profile');
                    setState(() {});
                  },
                  // onPressed: () =>
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  borderRadiusAll: AppStyle.buttonRadius.medium,
                  padding: MySpacing.xy(8, 4),
                  splashColor: theme.colorScheme.onBackground.withAlpha(20),
                  backgroundColor: Colors.transparent,
                  child: Row(
                    children: [
                      Icon(
                        FeatherIcons.user,
                        size: 14,
                        color: contentTheme.onBackground,
                      ),
                      MySpacing.width(8),
                      MyText.labelMedium(
                        "My Profile",
                        fontWeight: 600,
                      )
                    ],
                  ),
                ),
                MySpacing.height(4),
                MyButton(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () {
                    setState(() {
                      status = 'ok';
                    });
                    NavigatorHelper.pushNamed('/contacts/edit-profile');
                    setState(() {});
                  },
                  borderRadiusAll: AppStyle.buttonRadius.medium,
                  padding: MySpacing.xy(8, 4),
                  splashColor: theme.colorScheme.onBackground.withAlpha(20),
                  backgroundColor: Colors.transparent,
                  child: Row(
                    children: [
                      Icon(
                        FeatherIcons.edit,
                        size: 14,
                        color: contentTheme.onBackground,
                      ),
                      MySpacing.width(8),
                      MyText.labelMedium(
                        "Edit Profile",
                        fontWeight: 600,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          Padding(
            padding: MySpacing.xy(8, 8),
            child: MyButton(
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onPressed: () async {
                setState(() {
                  status = 'ok';
                });
                if (kIsWeb) {
                  await WebAuthService.logoutUser().then((value) {
                    NavigatorHelper.pushNamed('/auth/login');
                  });
                  await LocalStorage.setLoggedInUser(false);
                } else {
                  signOut();
                  NavigatorHelper.pushNamed('/auth/login');
                  await LocalStorage.setLoggedInUser(true);
                }
              },
              borderRadiusAll: AppStyle.buttonRadius.medium,
              padding: MySpacing.xy(8, 4),
              splashColor: contentTheme.danger.withAlpha(28),
              backgroundColor: Colors.transparent,
              child: Row(
                children: [
                  Icon(
                    FeatherIcons.logOut,
                    size: 14,
                    color: contentTheme.danger,
                  ),
                  MySpacing.width(8),
                  MyText.labelMedium(
                    "Log out",
                    fontWeight: 600,
                    color: contentTheme.danger,
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
