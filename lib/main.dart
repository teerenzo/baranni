import 'dart:io';

import 'package:barrani/helpers/config.dart';
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
import 'package:barrani/views/features/ecommerce/add_product.dart';
import 'package:barrani/views/features/ecommerce/products.dart';
import 'package:barrani/views/features/kanban_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:one_context/one_context.dart';

import 'helpers/localizations/language.dart';
import 'helpers/storage/local_storage.dart';
import 'helpers/theme/app_style.dart';
import 'helpers/theme/theme_customizer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: kIsWeb
        ? const FirebaseOptions(
            apiKey: Config.firebaseIosApiKey,
            projectId: Config.firebaseProjectId,
            storageBucket: Config.firebaseStorageBucket,
            messagingSenderId: Config.firebaseMessagingSenderId,
            appId: Config.firebaseIosAppId,
          )
        : Platform.isIOS
            ? const FirebaseOptions(
                apiKey: Config.firebaseIosApiKey,
                projectId: Config.firebaseProjectId,
                storageBucket: Config.firebaseStorageBucket,
                messagingSenderId: Config.firebaseMessagingSenderId,
                appId: Config.firebaseIosAppId,
              )
            : Platform.isAndroid
                ? const FirebaseOptions(
                    apiKey: Config.firebaseAndroidApiKey,
                    projectId: Config.firebaseProjectId,
                    storageBucket: Config.firebaseStorageBucket,
                    messagingSenderId: Config.firebaseMessagingSenderId,
                    appId: Config.firebaseAndroidAppId,
                  )
                : null,
  );
  await LocalStorage.init();
  AppStyle.init();
  // await ThemeCustomizer.init();
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  final List<NavigatorObserver> navigatorObservers;

  const MyApp({
    super.key,
    this.navigatorObservers = const <NavigatorObserver>[],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        ...navigatorObservers,
      ],
    );
  }
}
