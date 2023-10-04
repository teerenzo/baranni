import 'package:barrani/constants.dart';
import 'package:barrani/controller/features/calendar/calendar_controller.dart';
import 'package:barrani/global_functions.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/firebase/firestore.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/helpers/theme/app_style.dart';
import 'package:barrani/helpers/theme/app_theme.dart';
import 'package:barrani/helpers/utils/my_shadow.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb_item.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_card.dart';
import 'package:barrani/helpers/widgets/my_responsiv.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/my_text_style.dart';
import 'package:barrani/helpers/widgets/responsive.dart';
import 'package:barrani/models/invitation.dart';
import 'package:barrani/models/zone.dart';
import 'package:barrani/views/features/places/selector_zone.dart';
import 'package:barrani/views/layouts/layout.dart';
import 'package:barrani/widgets/appointment_detail.dart';
import 'package:barrani/widgets/appointment_dialog.dart';
import 'package:barrani/widgets/invitation_detail.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';

class Calender extends ConsumerStatefulWidget {
  static const routeName = "/calendar";
  final bool isMyCalendar;
  const Calender({Key? key, this.isMyCalendar = false}) : super(key: key);

  @override
  ConsumerState<Calender> createState() => _CalenderState();
}

class _CalenderState extends ConsumerState<Calender> with UIMixin {
  final CalendarController calendarController = CalendarController();
  PlaceZone? activeZone;
  bool isLoading = false;
  List<Appointment> calendarAppointments = [];

  List<Appointment> filterAppointments(List<Appointment> appointments) {
    List<Appointment> filteredAppointments = appointments.where((element) {
      bool isInZone = activeZone == null
          ? widget.isMyCalendar
          : element.location == activeZone?.id;
      bool isInviter = isUserAppointmentSender(element);
      bool isInvited =
          isUserInvitedToAppointment(element) && !widget.isMyCalendar;
      return isInZone && (isInvited || isInviter);
    }).toList();

    return filteredAppointments.map((e) {
      Appointment p = e;
      p.color = Colors.black38;
      if (!isUserAppointmentSender(p)) {
        Invitation invitation = getAppointedUserInvitation(p);
        p.color = getStatusColor(invitation.status, contentTheme);
      }
      return p;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var appointmentStream = ref.watch(kIsWeb
        ? FirebaseWebHelper.allAppointmentsStreamProvider
        : allAppointmentsStreamProvider);
    var zonesStream = ref.watch(kIsWeb
        ? FirebaseWebHelper.allZonesStreamProvider
        : allZonesStreamProvider);

    zonesStream.whenData((value) {
      if (!widget.isMyCalendar && activeZone == null) {
        setState(() {
          activeZone = value.first;
        });
      }
    });

    return Layout(
      child: Column(
        children: [
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: MyResponsive(
              builder: (BuildContext context, _, screenMT) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MyText.titleMedium(
                      "Calender",
                      fontWeight: 600,
                    ),
                    if (!widget.isMyCalendar)
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () {
                            _showStaticDialog(screenMT.isMobile);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            margin: EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  width: 0.4,
                                  color: Colors.grey,
                                )),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  activeZone != null
                                      ? activeZone!.name
                                      : 'Select Zone',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                      width: 20,
                    ),
                    MyButton(
                      onPressed: () =>
                          NavigatorHelper.pushNamed('/zone/manage'),
                      elevation: 0,
                      padding: MySpacing.xy(20, 16),
                      backgroundColor: contentTheme.primary,
                      borderRadiusAll: AppStyle.buttonRadius.medium,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_city,
                            color: Color(0xffffffff),
                          ),
                          MySpacing.width(8),
                          MyText.labelMedium(
                            'Manage Zones',
                            color: contentTheme.onPrimary,
                          ),
                        ],
                      ),
                    ),
                    if (!screenMT.isMobile)
                      Expanded(
                        flex: 3,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            MyBreadcrumb(
                              children: [
                                MyBreadcrumbItem(name: "Apps"),
                                MyBreadcrumbItem(
                                    name: widget.isMyCalendar
                                        ? "Calender"
                                        : "Appointments",
                                    active: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          MySpacing.height(flexSpacing),
          Padding(
            padding: MySpacing.x(flexSpacing),
            child: MyResponsive(
              builder: (_, __, type) {
                return MyCard(
                  shadow: MyShadow(elevation: 0.5),
                  height: 700,
                  child: appointmentStream.whenData(
                    (value) {
                      var appointments = value;
                      return SfCalendar(
                        key: UniqueKey(),
                        view: widget.isMyCalendar
                            ? CalendarView.day
                            : CalendarView.month,
                        allowedViews: const [
                          CalendarView.day,
                          CalendarView.week,
                          CalendarView.month,
                        ],
                        controller: calendarController,
                        dataSource:
                            DataSource(filterAppointments(appointments)),
                        allowDragAndDrop: false,
                        monthViewSettings: const MonthViewSettings(
                          showAgenda: true,
                        ),
                        onTap: (CalendarTapDetails calendarTapDetails) {
                          if (calendarTapDetails.targetElement ==
                              CalendarElement.calendarCell) {
                            if (calendarController.view == CalendarView.month) {
                              calendarController.view = CalendarView.week;
                            } else {
                              final DateTime pickedDate =
                                  calendarTapDetails.date!;
                              // if (isAppointmentExist(pickedDate)) {
                              //   return;
                              // }
                              if (type.isMobile) {
                                showModalBottomSheet(
                                  backgroundColor: theme.colorScheme.background,
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (BuildContext context) {
                                    return AppointmentDialog(
                                      isMobile: type.isMobile,
                                      startDate: pickedDate,
                                      zone: activeZone,
                                      onSave: (zone) {
                                        setState(() {
                                          // activeZone = zone;
                                        });
                                      },
                                    );
                                  },
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Builder(
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Make Appointment'),
                                          content: AppointmentDialog(
                                            isMobile: type.isMobile,
                                            startDate: pickedDate,
                                            zone: activeZone,
                                            onSave: (zone) {
                                              setState(() {
                                                activeZone = zone;
                                              });
                                            },
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                                return;
                              }
                            }
                          } else if (calendarTapDetails.targetElement ==
                              CalendarElement.appointment) {
                            Appointment appointment =
                                getAppointmentByDate(calendarTapDetails.date!);
                            final isInviter =
                                isUserAppointmentSender(appointment);
                            if (type.isMobile) {
                              showModalBottomSheet(
                                useSafeArea: true,
                                backgroundColor: theme.colorScheme.background,
                                context: context,
                                isScrollControlled: true,
                                builder: (BuildContext context) {
                                  return isInviter
                                      ? AppointmentDetail(
                                          isMobile: type.isMobile,
                                          appointment: appointment,
                                        )
                                      : InvitationDetail(
                                          isMobile: type.isMobile,
                                          appointment: appointment,
                                        );
                                },
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Builder(
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${isInviter ? 'Appointment' : 'Invitation'} Detail',
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(10),
                                                child: Icon(
                                                  LucideIcons.x,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        content: isInviter
                                            ? AppointmentDetail(
                                                isMobile: type.isMobile,
                                                appointment: appointment,
                                              )
                                            : InvitationDetail(
                                                isMobile: type.isMobile,
                                                appointment: appointment,
                                              ),
                                      );
                                    },
                                  );
                                },
                              );
                            }
                          }
                        },
                      );
                    },
                  ).when(
                    loading: () => Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => MyText.bodyMedium(
                      'Error loading appointments $error',
                      fontWeight: 600,
                      muted: true,
                      color: kAlertColor,
                      textAlign: TextAlign.start,
                    ),
                    data: (Widget appointmentData) {
                      return appointmentData;
                    },
                  ),
                );
              },
            ),
          ),
        ],
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

  void _showStaticDialog(bool isMobile) {
    isMobile
        ? showModalBottomSheet(
            context: context,
            backgroundColor: theme.colorScheme.background,
            builder: (_) {
              return SelectZone(
                isMobile: isMobile,
                activeZone: activeZone,
                setZone: (value) {
                  setState(() {
                    activeZone = value;
                  });
                },
              );
            },
          )
        : showDialog(
            context: context,
            builder: (_) {
              return Dialog(
                child: SelectZone(
                  isMobile: isMobile,
                  activeZone: activeZone,
                  setZone: (value) {
                    setState(() {
                      activeZone = value;
                    });
                  },
                ),
              );
            },
          );
  }
}
