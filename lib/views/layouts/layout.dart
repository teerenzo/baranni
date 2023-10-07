import 'package:barrani/controller/layouts/layout_controller.dart';
import 'package:barrani/data/providers/auth/authentication_provider.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/firebase/auth.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/localizations/language.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/helpers/services/web_auth_services.dart';
import 'package:barrani/helpers/storage/local_storage.dart';
import 'package:barrani/helpers/theme/admin_theme.dart';
import 'package:barrani/helpers/theme/app_style.dart';

import 'package:barrani/helpers/theme/theme_customizer.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_dashed_divider.dart';
import 'package:barrani/helpers/widgets/my_responsiv.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/responsive.dart';
import 'package:barrani/images.dart';
import 'package:barrani/models/notification.dart';
import 'package:barrani/views/layouts/left_bar.dart';
import 'package:barrani/views/layouts/notification_popUp.dart';
import 'package:barrani/views/layouts/right_bar.dart';
import 'package:barrani/views/layouts/top_bar.dart';
import 'package:barrani/widgets/custom_pop_menu.dart';
import 'package:feather_icons/feather_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class Layout extends ConsumerStatefulWidget {
  final Widget? child;

  Layout({super.key, this.child});

  @override
  ConsumerState<Layout> createState() => _LayoutState();
}

class _LayoutState extends ConsumerState<Layout> {
  Function? languageHideFn;
  final LayoutController controller = LayoutController();

  final topBarTheme = AdminTheme.theme.topBarTheme;

  final contentTheme = AdminTheme.theme.contentTheme;
  String status = '';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    status = '';
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('powr', 'powr.com',
            channelDescription: 'powr.com',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
        133, null, 'you have new notification(s)', notificationDetails,
        payload: 'item x');
  }

  @override
  Widget build(BuildContext context) {
    var userNotifications = ref.watch(kIsWeb
        ? FirebaseWebHelper.userNotificationsStreamProvider
        : userNotificationsStreamProvider);

    // check if notification time is less done 2 minutes and not read and show snackbar
    var notification = notifications
        .where((element) =>
            DateTime.now().difference(element.createdAt).inMinutes <= 2)
        .toList();
    if (notification.isNotEmpty) {
      _showNotification();
    }

    return MyResponsive(builder: (BuildContext context, _, screenMT) {
      return GetBuilder(
          init: controller,
          builder: (controller) {
            return screenMT.isMobile
                ? mobileScreen(userNotifications)
                : largeScreen();
          });
    });
  }

  Widget mobileScreen(AsyncValue<List<NotificationModal>> userNotifications) {
    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        actions: [
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
          MySpacing.width(8),
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
          MySpacing.width(8),
          CustomPopupMenu(
            backdrop: true,
            onChange: (_) {},
            offsetX: -180,
            menu: Padding(
              padding: MySpacing.xy(8, 8),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      FeatherIcons.bell,
                      size: 18,
                    ),
                    userNotifications.whenData((value) {
                      return value.isEmpty
                          ? Container()
                          : Positioned(
                              top: 0,
                              right: 0,
                              child: MyContainer.rounded(
                                width: 9,
                                height: 9,
                                color: contentTheme.danger,
                              ),
                            );
                    }).when(data: (Widget data) {
                      return data;
                    }, error: (error, stack) {
                      return Container();
                    }, loading: () {
                      return Container();
                    })
                  ],
                ),
              ),
            ),
            menuBuilder: (_) => NotificationPopUp(contentTheme: contentTheme),
          ),
          MySpacing.width(8),
          CustomPopupMenu(
            backdrop: true,
            onChange: (_) {
              ref.read(authProvider.notifier).closeMenu();
            },
            offsetX: -90,
            offsetY: 4,
            menu: Padding(
              padding: MySpacing.xy(8, 8),
              child: userData?.photoUrl == null || userData!.photoUrl.isEmpty
                  ? MyContainer.rounded(
                      paddingAll: 0,
                      child: Image.asset(
                        Images.avatars[0],
                        height: 28,
                        width: 28,
                        fit: BoxFit.cover,
                      ))
                  : MyContainer.rounded(
                      paddingAll: 0,
                      child: Image.network(
                        userData!.photoUrl,
                        height: 28,
                        width: 28,
                        fit: BoxFit.cover,
                      )),
            ),
            menuBuilder: (_) => userData != null && status == ''
                ? buildAccountMenu()
                : Container(),
          ),
          MySpacing.width(20)
        ],
      ), // endDrawer: RightBar(),
      // extendBodyBehindAppBar: true,
      // appBar: TopBar(
      drawer: LeftBar(),
      body: SingleChildScrollView(
        key: controller.scrollKey,
        child: widget.child,
      ),
    );
  }

  Widget largeScreen() {
    return Scaffold(
      key: controller.scaffoldKey,
      endDrawer: RightBar(),
      body: Row(
        children: [
          LeftBar(isCondensed: ThemeCustomizer.instance.leftBarCondensed),
          Expanded(
              child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                bottom: 0,
                child: SingleChildScrollView(
                  padding:
                      MySpacing.fromLTRB(0, 58 + flexSpacing, 0, flexSpacing),
                  key: controller.scrollKey,
                  child: widget.child,
                ),
              ),
              Positioned(top: 0, left: 0, right: 0, child: TopBar()),
            ],
          )),
        ],
      ),
    );
  }

  Widget buildNotifications() {
    Widget buildNotification(String title, String description) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.labelLarge(title),
          MySpacing.height(4),
          MyText.bodySmall(description)
        ],
      );
    }

    return MyContainer.bordered(
      paddingAll: 0,
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.xy(16, 12),
            child: MyText.titleMedium("Notification", fontWeight: 600),
          ),
          MyDashedDivider(
              height: 1, color: theme.dividerColor, dashSpace: 4, dashWidth: 6),
          Padding(
            padding: MySpacing.xy(16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildNotification("Your order is received",
                    "Order #1232 is ready to deliver"),
                MySpacing.height(12),
                buildNotification("Account Security ",
                    "Your account password changed 1 hour ago"),
              ],
            ),
          ),
          MyDashedDivider(
              height: 1, color: theme.dividerColor, dashSpace: 4, dashWidth: 6),
          Padding(
            padding: MySpacing.xy(16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MyButton.text(
                  onPressed: () {},
                  splashColor: contentTheme.primary.withAlpha(28),
                  child: MyText.labelSmall(
                    "View All",
                    color: contentTheme.primary,
                  ),
                ),
                MyButton.text(
                  onPressed: () {},
                  splashColor: contentTheme.danger.withAlpha(28),
                  child: MyText.labelSmall(
                    "Clear",
                    color: contentTheme.danger,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Widget buildAccountMenu() {
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
                    ref.read(authProvider).copyWith(openMenu: false);
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
                    ref.read(authProvider).copyWith(openMenu: false);

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
                    ref.read(authProvider).copyWith(openMenu: false);
                  });
                  await LocalStorage.setLoggedInUser(false);
                } else {
                  signOut();
                  NavigatorHelper.pushNamed('/auth/login');
                  await LocalStorage.setLoggedInUser(true);
                }
                ref.read(authProvider).copyWith(openMenu: false);
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
                    // await Provider.of<AppNotifier>(context, listen: false)
                    //     .changeLanguage(language, notify: true);
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
}
