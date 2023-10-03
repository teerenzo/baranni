import 'package:barrani/global_variables.dart';
import 'package:barrani/views/auth/forgot_password.dart';
import 'package:barrani/views/auth/login.dart';
import 'package:barrani/views/auth/register.dart';
import 'package:barrani/views/auth/reset_password.dart';
import 'package:barrani/views/features/calendar.dart';
import 'package:barrani/views/features/chat_page.dart';
import 'package:barrani/views/features/contacts/edit_profile.dart';
import 'package:barrani/views/features/contacts/member_list.dart';
import 'package:barrani/views/features/contacts/profile.dart';
import 'package:barrani/views/features/kanban_page.dart';
import 'package:barrani/views/starter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'views/dashboard.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return userData != null ? null : const RouteSettings(name: '/auth/login');
  }
}

class UserMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return userData == null ? null : const RouteSettings(name: '/dashboard');
  }
}

getPageRoute() {
  return [
    ///---------------- Auth ----------------///

    GetPage(
      name: '/auth/login',
      page: () => const LoginPage(),
      middlewares: [UserMiddleware()],
    ),
    GetPage(
      name: '/auth/register',
      page: () => const Register(),
      middlewares: [UserMiddleware()],
    ),
    GetPage(
      name: '/auth/reset-password',
      page: () => const ResetPassword(),
      middlewares: [UserMiddleware()],
    ),
    GetPage(
      name: '/auth/forgot_password',
      page: () => const ForgotPassword(),
      middlewares: [UserMiddleware()],
    ),

    /// ------------ dashboard ------------ ///

    GetPage(
      name: '/dashboard',
      page: () => const DashboardPage(),
      middlewares: [AuthMiddleware()],
    ),

    GetPage(
        name: '/',
        page: () => const DashboardPage(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/starter',
        page: () => const Starter(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/dashboard',
        page: () => const DashboardPage(),
        middlewares: [AuthMiddleware()]),

    ///---------------- KanBan ----------------///

    GetPage(
        name: '/kanban',
        page: () => const KanBanPage(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Contacts ----------------///

    GetPage(
        name: '/contacts/profile',
        page: () => const ProfilePage(),
        middlewares: [AuthMiddleware()]),
    GetPage(
        name: '/contacts/members',
        page: () => const MemberList(),
        middlewares: [AuthMiddleware()]),

    GetPage(
        name: '/contacts/edit-profile',
        page: () => const EditProfile(),
        middlewares: [AuthMiddleware()]),

    ///---------------- Error ----------------///
    GetPage(
        name: '/calender',
        page: () => const Calender(),
        middlewares: [AuthMiddleware()]),

    GetPage(
      name: '/chat',
      page: () => const ChatPage(),
      // middlewares: [AuthMiddleware()]
    ),
  ];
}
