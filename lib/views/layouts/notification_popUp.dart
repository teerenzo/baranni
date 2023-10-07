import 'package:barrani/constants.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/theme/admin_theme.dart';

import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_dashed_divider.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationPopUp extends ConsumerWidget {
  const NotificationPopUp({
    super.key,
    required this.contentTheme,
  });

  final ContentTheme contentTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget buildNotification(String title, String description) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MyText.labelLarge(
            title,
            color: contentTheme.onBackground,
          ),
          MySpacing.height(4),
          MyText.bodySmall(
            description,
            color: contentTheme.onBackground,
          )
        ],
      );
    }

    var userNotifications = ref.watch(kIsWeb
        ? FirebaseWebHelper.userNotificationsStreamProvider
        : userNotificationsStreamProvider);

    return MyContainer.bordered(
      paddingAll: 0,
      width: 250,
      color: contentTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: MySpacing.xy(16, 12),
            child: MyText.titleMedium(
              "Notification",
              fontWeight: 600,
              color: contentTheme.onBackground,
            ),
          ),
          MyDashedDivider(
            height: 1,
            color: theme.dividerColor,
            dashSpace: 4,
            dashWidth: 6,
          ),
          Padding(
            padding: MySpacing.xy(16, 12),
            child: userNotifications.whenData((value) {
              return notifications.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: notifications
                          .map((e) => Column(
                                children: [
                                  buildNotification(e.title, e.body),
                                  MySpacing.height(12),
                                ],
                              ))
                          .toList(),
                    )
                  : MyText.bodyMedium('No notification');
            }).when(
              data: (Widget data) {
                return data;
              },
              error: (error, stack) => Center(
                child: MyText.bodyMedium(
                  'Error loading users $error',
                  fontWeight: 600,
                  muted: true,
                  color: kAlertColor,
                  textAlign: TextAlign.start,
                ),
              ),
              loading: () => Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          MyDashedDivider(
              height: 1, color: theme.dividerColor, dashSpace: 4, dashWidth: 6),
          Padding(
            padding: MySpacing.xy(16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyButton.text(
                  onPressed: () {
                    notifications.forEach((element) {
                      kIsWeb
                          ? FirebaseWebHelper.deleteNotification(element.id)
                          : deleteNotification(element.id);
                    });
                  },
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
}
