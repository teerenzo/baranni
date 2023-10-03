import 'package:barrani/controller/features/chat_controller.dart';
import 'package:barrani/helpers/theme/app_theme.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/models/ChatAppointment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: must_be_immutable
class InvidualUserChat extends StatelessWidget {
  Attendees attendee;
  Function() onSelected;
  InvidualUserChat(
      {super.key, required this.attendee, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final controller = ref.watch(chatControllerProvider);
        return MyButton(
          onPressed: onSelected,
          elevation: 0,
          borderRadiusAll: 8,
          backgroundColor:
              controller.currentSelectedUser['userId'] == attendee.userId
                  ? theme.colorScheme.primary.withOpacity(0.2)
                  : theme.colorScheme.background.withAlpha(5),
          splashColor: theme.colorScheme.onBackground.withAlpha(10),
          child: SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MyContainer.rounded(
                    border: Border.all(
                      // color: theme.colorScheme.onBackground.withOpacity(0.2),
                      width: 3,
                    ),
                    height: 40,
                    width: 40,
                    paddingAll: 0,
                    alignment: Alignment.center,
                    child: ((attendee.profileUrl != null &&
                            attendee.profileUrl!.isNotEmpty))
                        ? Image.network(attendee.profileUrl!)
                        : Text("${attendee.names![0]}".toUpperCase(),
                            style: TextStyle(
                              color: theme.colorScheme.onBackground,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            )),
                  ),
                  MySpacing.width(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MyText.labelLarge(
                          "${attendee.names} ",
                        ),
                        SizedBox(
                          width: 200,
                          child: MyText.bodySmall(
                            "${attendee.email}",
                            muted: true,
                            overflow: TextOverflow.ellipsis,
                            fontWeight: 400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        );
      },
    );
  }
}
