import 'package:barrani/app_constant.dart';
import 'package:barrani/global_functions.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/services/appointment_web_services.dart';
import 'package:barrani/helpers/theme/app_style.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_flex.dart';
import 'package:barrani/helpers/widgets/my_flex_item.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/my_text_style.dart';
import 'package:barrani/models/invitation.dart';
import 'package:barrani/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class InvitationDetail extends StatefulWidget {
  final Appointment appointment;
  final bool isMobile;
  InvitationDetail({
    super.key,
    required this.isMobile,
    required this.appointment,
  });

  @override
  State<InvitationDetail> createState() => _InvitationDetailState();
}

class _InvitationDetailState extends State<InvitationDetail> with UIMixin {
  bool isAccepting = false;
  bool isDeclining = false;

  Future<void> handleAccept() async {
    setState(() {
      isAccepting = true;
    });
    Invitation invitation = getAppointedUserInvitation(widget.appointment);
    kIsWeb
        ? await webUpdateInvitation(invitation, 'accepted')
            .then((value) => Navigator.pop(context))
        : await updateInvitation(invitation, 'accepted')
            .then((value) => Navigator.pop(context));

    setState(() {
      isAccepting = false;
    });
  }

  Future<void> handleDecline() async {
    setState(() {
      isDeclining = true;
    });

    Invitation invitation = getAppointedUserInvitation(widget.appointment);
    kIsWeb
        ? await webUpdateInvitation(invitation, 'declined')
            .then((value) => Navigator.pop(context))
        : await updateInvitation(invitation, 'declined')
            .then((value) => Navigator.pop(context));

    setState(() {
      isDeclining = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Invitation invitation;
    try {
      invitation = getAppointedUserInvitation(widget.appointment);
    } catch (error) {
      print(widget.appointment.id);
      return MyContainer(
        height: 300,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Center(child: MyText.bodyMedium('No invitation found')),
      );
    }
    bool isAccepted = invitation.status == 'accepted';
    bool isDeclined = invitation.status == 'declined';
    UserModal hoster = findUser(invitation.senderId);
    List<Invitation> invitations =
        getInvitationsByAppointmentId(widget.appointment.id.toString());
    String? imgUrl = widget.appointment.recurrenceId?.toString();
    return SingleChildScrollView(
      child: MyContainer(
        width: MediaQuery.of(context).size.width * (widget.isMobile ? 1 : 0.4),
        height: widget.isMobile
            ? MediaQuery.of(context).size.height *
                (isAccepted ? 0.82 : (isDeclined ? 0.68 : 0.8))
            : 620,
        padding: EdgeInsets.all(widget.isMobile ? 16 : 30),
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
                              widget.appointment.notes!,
                              fontWeight: 600,
                              muted: true,
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                        MySpacing.height(16),
                        MySpacing.height(16),
                        Row(
                          children: [
                            MyText.bodyMedium(
                              "Host",
                              fontWeight: 700,
                              textAlign: TextAlign.start,
                            ),
                            MySpacing.width(16),
                            MyText.bodyMedium(
                              hoster.names,
                              fontWeight: 600,
                              muted: true,
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                        MySpacing.height(16),
                        MySpacing.height(16),
                        Row(
                          children: [
                            MyText.bodyMedium(
                              "Status",
                              fontWeight: 700,
                              textAlign: TextAlign.start,
                            ),
                            MySpacing.width(16),
                            MyContainer(
                              padding: MySpacing.xy(12, 2),
                              color: getStatusColor(
                                  invitation.status, contentTheme),
                              child: MyText.bodyMedium(
                                capitalize(invitation.status),
                                fontSize: 12,
                                color: getStatusBgColor(
                                    invitation.status, contentTheme),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
                    if (imgUrl != null) Expanded(child: Image.network(imgUrl))
                  ],
                ),
                MySpacing.height(16),
                if (isAccepted)
                  Container(
                    alignment: Alignment.centerLeft,
                    child: MyText.bodyMedium(
                      "Invites",
                      fontWeight: 700,
                      textAlign: TextAlign.start,
                    ),
                  ),
                if (isAccepted) MySpacing.height(8),
                if (isAccepted)
                  SizedBox(
                    height: 70,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: invitations.map((e) {
                        return InviteAvatar(
                          invitation: e,
                          isMobile: true,
                        );
                      }).toList(),
                    ),
                  ),
                MySpacing.height(16),
                if (widget.appointment.notes != null) MySpacing.height(8),
                if (widget.appointment.notes != null)
                  Container(
                    alignment: Alignment.centerLeft,
                    child: MyText.bodyMedium(
                      widget.appointment.subject,
                      fontWeight: 600,
                      muted: true,
                      textAlign: TextAlign.start,
                    ),
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
                      dateFormatter.format(widget.appointment.endTime),
                      fontWeight: 600,
                      muted: true,
                      textAlign: TextAlign.start,
                    ),
                  ],
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
                                    widget.appointment.startTime,
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
                                    widget.appointment.endTime,
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
                SizedBox(height: 16),
                // action buttons
                if (invitation.status == 'pending')
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: MyButton.block(
                            backgroundColor: theme.colorScheme.error,
                            borderRadiusAll: AppStyle.buttonRadius.medium,
                            elevation: 0,
                            onPressed: () {
                              if (isAccepting || isDeclining) {
                                return;
                              }
                              handleDecline();
                            },
                            child: MyText.bodyLarge(
                              isDeclining ? 'Declining' : 'Decline',
                              fontWeight: 600,
                              color: theme.colorScheme.onError,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: MyButton.block(
                            backgroundColor: theme.colorScheme.primary
                                .withOpacity(
                                    isAccepting || isDeclining ? 0.8 : 1),
                            borderRadiusAll: AppStyle.buttonRadius.medium,
                            elevation: 0,
                            onPressed: () {
                              handleAccept();
                            },
                            child: MyText.bodyLarge(
                              isAccepting ? 'Accepting' : 'Accept',
                              fontWeight: 600,
                              color: theme.colorScheme.onError,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
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
      margin: const EdgeInsets.only(right: 10),
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
                            child: MyText.labelLarge(
                                user.names[0].split(' ').first),
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
