import 'package:barrani/helpers/theme/app_theme.dart';
import 'package:barrani/helpers/utils/utils.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/images.dart';
import 'package:barrani/models/ChatInvitation.dart';
import 'package:flutter/material.dart';

class SingleGroup extends StatelessWidget {
  final ChatInvitation data;
  const SingleGroup({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    var appointmentInfo = data.appointmentInfo;
    DateTime startDate = appointmentInfo!.startTime!;
    DateTime endDate = appointmentInfo.endTime!;
    return InkWell(
      onTap: () {
        // controller.setCurrentSelectedGroup(data.groupId);
      },
      child: MyButton(
        onPressed: () {
          // controller.setCurrentSelectedGroup(data.groupId);
        },
        elevation: 0,
        borderRadiusAll: 8,
        backgroundColor: theme.colorScheme.background.withAlpha(5),
        splashColor: theme.colorScheme.onBackground.withAlpha(10),
        child: SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyContainer.rounded(
                height: 40,
                width: 40,
                paddingAll: 0,
                child: Image.asset(
                  Images.avatars[1],
                  height: 40,
                  width: 40,
                  fit: BoxFit.cover,
                ),
              ),
              MySpacing.width(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText.labelLarge(
                      // data!,

                      "",
                      fontWeight: 600,
                    ),
                    MyText.bodyMedium(
                      "${Utils.getTimeStringFromDateTime(startDate, showSecond: false)} - ${Utils.getTimeStringFromDateTime(endDate, showSecond: false)}",
                      muted: true,
                      fontWeight: 600,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
