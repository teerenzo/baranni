import 'dart:async';
import 'dart:io';

import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/config.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/views/auth/forgot_password.dart';
import 'package:barrani/views/auth/login.dart';
import 'package:barrani/views/auth/register.dart';
import 'package:barrani/views/auth/reset_password.dart';
import 'package:barrani/views/dashboard.dart';
import 'package:barrani/views/features/add_kanban_task.dart';
import 'package:barrani/views/features/calendar.dart';
import 'package:barrani/views/features/chat_page.dart';
import 'package:barrani/views/features/contacts/edit_profile.dart';
import 'package:barrani/views/features/contacts/profile.dart';
import 'package:barrani/views/features/kanban_page.dart';
import 'package:barrani/views/features/ecommerce/add_product.dart';
import 'package:barrani/views/features/ecommerce/products.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firedart/firedart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:one_context/one_context.dart';

import 'helpers/localizations/language.dart';
import 'helpers/storage/local_storage.dart';
import 'helpers/theme/app_style.dart';
import 'helpers/theme/theme_customizer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

int id = 0;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
final StreamController<ReceivedNotification> didReceiveLocalNotificationStream =
    StreamController<ReceivedNotification>.broadcast();

final StreamController<String?> selectNotificationStream =
    StreamController<String?>.broadcast();

const MethodChannel platform =
    MethodChannel('dexterx.dev/flutter_local_notifications_example');

const String portName = 'notification_send_port';

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}

String? selectedNotificationPayload;

const String urlLaunchActionId = 'id_1';

const String navigationActionId = 'id_3';

const String darwinNotificationCategoryText = 'textCategory';

const String darwinNotificationCategoryPlain = 'plainCategory';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _configureLocalTimeZone();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');
  initializationSettingsAndroid.defaultIcon;

  final List<DarwinNotificationCategory> darwinNotificationCategories =
      <DarwinNotificationCategory>[
    DarwinNotificationCategory(
      darwinNotificationCategoryText,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.text(
          'text_1',
          'Action 1',
          buttonTitle: 'Send',
          placeholder: 'Placeholder',
        ),
      ],
    ),
    DarwinNotificationCategory(
      darwinNotificationCategoryPlain,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2 (destructive)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          navigationActionId,
          'Action 3 (foreground)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
        DarwinNotificationAction.plain(
          'id_4',
          'Action 4 (auth required)',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.authenticationRequired,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ];

  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification:
        (int id, String? title, String? body, String? payload) async {
      didReceiveLocalNotificationStream.add(
        ReceivedNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
        ),
      );
    },
    notificationCategories: darwinNotificationCategories,
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
    macOS: initializationSettingsDarwin,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) {
      switch (notificationResponse.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          selectNotificationStream.add(notificationResponse.payload);
          break;
        case NotificationResponseType.selectedNotificationAction:
          if (notificationResponse.actionId == navigationActionId) {
            selectNotificationStream.add(notificationResponse.payload);
          }
          break;
      }
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  if (kIsWeb) {
    await FirebaseWebHelper.init();
  } else {
    Firestore.initialize(Config.firebaseProjectId);
    try {
      if (Platform.isIOS || Platform.isMacOS) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: Config.firebaseIosApiKey,
            projectId: Config.firebaseProjectId,
            storageBucket: Config.firebaseStorageBucket,
            messagingSenderId: Config.firebaseMessagingSenderId,
            appId: Config.firebaseIosAppId,
          ),
        );
      } else if (Platform.isAndroid) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: Config.firebaseAndroidApiKey,
            projectId: Config.firebaseProjectId,
            storageBucket: Config.firebaseStorageBucket,
            messagingSenderId: Config.firebaseMessagingSenderId,
            appId: Config.firebaseAndroidAppId,
          ),
        );
      }
    } catch (err) {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
    }
    FirebaseAuth.initialize(Config.firebaseIosApiKey, VolatileStore());
  }
  await LocalStorage.init();
  AppStyle.init();
  // await ThemeCustomizer.init();
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

<<<<<<< HEAD
Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

class MyApp extends ConsumerWidget {
=======
class MyApp extends ConsumerStatefulWidget {
>>>>>>> 0f214ff (fix calendar and profile issues)
  final List<NavigatorObserver> navigatorObservers;

  const MyApp({
    super.key,
    this.navigatorObservers = const <NavigatorObserver>[],
  });

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    userData = LocalStorage.getLocalUserData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeCustomizer.instance.theme,
      navigatorKey: OneContext().key,
      builder: OneContext().builder,
      initialRoute: "/auth/login",
      routes: {
        DashboardPage.routeName: (context) => DashboardPage(),

        // AUTH
        LoginPage.routeName: (context) => LoginPage(),
        Register.routeName: (context) => Register(),
        ResetPassword.routeName: (context) => ResetPassword(),
        ForgotPassword.routeName: (context) => ForgotPassword(),

        // PROFILE
        EditProfile.routeName: (context) => EditProfile(),
        ProfilePage.routeName: (context) => ProfilePage(),

        // DASHBOARD
        Calender.routeName: (context) => Calender(),
        '/my-calendar': (context) => Calender(isMyCalendar: true),
        ChatPage.routeName: (context) => ChatPage(),

        //KANBAN
        KanBanPage.routeName: (context) => KanBanPage(),
        AddTask.routeName: (context) => AddTask(),
        // product pages
        ProductPage.routeName: (context) => ProductPage(),
        AddProduct.routeName: (context) => AddProduct(),
      },
      localizationsDelegates: const [
        // AppLocalizationsDelegate(context),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: Language.getLocales(),
      navigatorObservers: [
        ...widget.navigatorObservers,
      ],
    );
  }
}
