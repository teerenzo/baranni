import 'dart:io';

import 'package:barrani/app_constant.dart';
import 'package:barrani/controller/features/chat_controller.dart';
import 'package:barrani/global_functions.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/helpers/theme/app_theme.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_flex.dart';
import 'package:barrani/helpers/widgets/my_flex_item.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/my_text_style.dart';
import 'package:barrani/models/invitation.dart';
import 'package:barrani/views/features/mobile_chat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';

class AppointmentDetail extends StatelessWidget {
  final Appointment appointment;
  final bool isMobile;
  AppointmentDetail({
    super.key,
    required this.isMobile,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    List<Invitation> invitations =
        getInvitationsByAppointmentId(appointment.id.toString());
    String? imgUrl = appointment.recurrenceId?.toString();
    return Container(
      width: MediaQuery.of(context).size.width * (isMobile ? 1 : 0.4),
      height: isMobile ? MediaQuery.of(context).size.height * 0.7 : 700,
      padding: EdgeInsets.all(isMobile ? 16 : 0),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            MyText.bodyMedium(
                              "Zone",
                              fontWeight: 700,
                              textAlign: TextAlign.start,
                            ),
                            MySpacing.width(16),
                            MyText.bodyMedium(
                              appointment.notes!,
                              fontWeight: 600,
                              muted: true,
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                        MySpacing.height(16),
                        Row(
                          children: [
                            MyText.bodyMedium(
                              "Date",
                              fontWeight: 700,
                              textAlign: TextAlign.start,
                            ),
                            MySpacing.width(16),
                            MyText.bodyMedium(
                              dateFormatter.format(appointment.endTime),
                              fontWeight: 600,
                              muted: true,
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (imgUrl != null)
                    Expanded(
                      child: Image.network(
                        imgUrl,
                        width: 300,
                        height: 300,
                        fit: BoxFit.cover,
                      ),
                    ),
                ],
              ),
              MySpacing.height(16),
              Container(
                alignment: Alignment.centerLeft,
                child: MyText.bodyMedium(
                  "Invites",
                  fontWeight: 700,
                  textAlign: TextAlign.start,
                ),
              ),
              MySpacing.height(8),
              SizedBox(
                height: 70,
                child: Consumer(builder:
                    (BuildContext context, WidgetRef ref, Widget? child) {
                  final chat = ref.watch(chatControllerProvider);
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    children: invitations.map((e) {
                      return GestureDetector(
                        onTap: () {
                          if (kIsWeb ||
                              Platform.isWindows ||
                              Platform.isMacOS ||
                              Platform.isLinux) {
                            chat.setCurrentSelectedUser(
                                {'userId': e.receiverId});

                            NavigatorHelper.pushNamed('/chat');
                            Navigator.of(context).pop();
                          } else {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                              return MobileChat(
                                type: "chat",
                                currentUser: e.receiverId,
                              );
                            }));
                          }
                        },
                        child: InviteAvatar(
                          invitation: e,
                          isMobile: isMobile,
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
              MySpacing.height(16),
              MySpacing.height(16),
              Container(
                alignment: Alignment.centerLeft,
                child: MyText.bodyMedium(
                  "Description",
                  fontWeight: 700,
                  textAlign: TextAlign.start,
                ),
              ),
              if (appointment.notes != null) MySpacing.height(8),
              if (appointment.notes != null)
                Container(
                  alignment: Alignment.centerLeft,
                  child: MyText.bodyMedium(
                    appointment.subject,
                    fontWeight: 600,
                    muted: true,
                    textAlign: TextAlign.start,
                  ),
                ),
              MySpacing.height(16),
              MyFlex(
                contentPadding: false,
                children: [
                  MyFlexItem(
                    sizes: "lg-6",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.bodyMedium(
                          "Start Time",
                          fontWeight: 700,
                        ),
                        MySpacing.height(8),
                        MyContainer.bordered(
                          paddingAll: 12,
                          onTap: () {},
                          borderColor: theme.colorScheme.secondary,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                LucideIcons.calendar,
                                color: theme.colorScheme.secondary,
                                size: 16,
                              ),
                              MySpacing.width(10),
                              MyText.bodyMedium(
                                timeHourFormatter.format(
                                  appointment.startTime,
                                ),
                                fontWeight: 600,
                                color: theme.colorScheme.secondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  MyFlexItem(
                    sizes: "lg-6",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText.bodyMedium(
                          "End Time",
                          fontWeight: 700,
                        ),
                        MySpacing.height(8),
                        MyContainer.bordered(
                          paddingAll: 12,
                          onTap: () {},
                          borderColor: theme.colorScheme.secondary,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Icon(
                                LucideIcons.calendar,
                                color: theme.colorScheme.secondary,
                                size: 16,
                              ),
                              MySpacing.width(10),
                              MyText.bodyMedium(
                                timeHourFormatter.format(
                                  appointment.endTime,
                                ),
                                fontWeight: 600,
                                color: theme.colorScheme.secondary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  buildTextField(String fieldTitle, String hintText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.labelMedium(
          fieldTitle,
        ),
        MySpacing.height(8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: MyTextStyle.bodySmall(xMuted: true),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
              borderSide: BorderSide(
                  width: 1,
                  strokeAlign: 0,
                  color: theme.colorScheme.onBackground.withAlpha(80)),
            ),
            contentPadding: MySpacing.all(16),
            isCollapsed: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
        ),
      ],
    );
  }
}

class InviteAvatar extends StatefulWidget {
  final Invitation invitation;
  final bool isMobile;
  const InviteAvatar({
    Key? key,
    required this.invitation,
    this.isMobile = false,
  }) : super(key: key);

  @override
  State<InviteAvatar> createState() => _InviteAvatarState();
}

class _InviteAvatarState extends State<InviteAvatar> with UIMixin {
  @override
  Widget build(BuildContext context) {
    final user = findUser(widget.invitation.receiverId);
    return Container(
      constraints: BoxConstraints(
        maxWidth: 180,
      ),
      child: MyButton(
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
              Stack(
                alignment: Alignment.center,
                children: [
                  MyContainer.rounded(
                    height: 40,
                    width: 40,
                    paddingAll: 0,
                    color: theme.scaffoldBackgroundColor,
                    child: user.photoUrl != ""
                        ? Image.network(
                            user.photoUrl,
                            height: 40,
                            width: 40,
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: MyText.labelLarge(user.names[0]),
                          ),
                  ),
                ],
              ),
              MySpacing.width(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText.labelLarge(
                      user.names.split(' ').first,
                    ),
                    MyContainer(
                      padding: MySpacing.xy(12, 2),
                      color: getStatusColor(
                          widget.invitation.status, contentTheme),
                      child: MyText.bodyMedium(
                        capitalize(widget.invitation.status),
                        fontSize: 12,
                        color: getStatusBgColor(
                            widget.invitation.status, contentTheme),
                      ),
                    )
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
