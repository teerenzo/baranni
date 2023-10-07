import 'dart:io';

import 'package:barrani/controller/features/chat_controller.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/firebase/firebase_web_helper.dart';
import 'package:barrani/helpers/services/chat_services.dart';
import 'package:barrani/helpers/theme/app_style.dart';

import 'package:barrani/helpers/utils/my_shadow.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:barrani/helpers/utils/utils.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb.dart';
import 'package:barrani/helpers/widgets/my_breadcrumb_item.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_card.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_dotted_line.dart';
import 'package:barrani/helpers/widgets/my_flex.dart';
import 'package:barrani/helpers/widgets/my_flex_item.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/my_text_style.dart';
import 'package:barrani/helpers/widgets/responsive.dart';
import 'package:barrani/images.dart';
import 'package:barrani/models/ChatInvitation.dart';
import 'package:barrani/views/features/mobile_chat.dart';
import 'package:barrani/views/layouts/layout.dart';
import 'package:barrani/widgets/IndividualUser.dart';
import 'package:barrani/widgets/SingleChat.dart';
import 'package:barrani/widgets/SingleInvividual.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatPage extends ConsumerStatefulWidget {
  static const String routeName = "/chat";
  const ChatPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage>
    with SingleTickerProviderStateMixin, UIMixin {
  @override
  void initState() {
    super.initState();
  }

  final ScrollController groupScrollController = ScrollController();
  final ScrollController scrollController =
      ScrollController(initialScrollOffset: 999999.0);

  void scrollToBottom(String type) {
    if (type == "group") {
      groupScrollController.animateTo(
        groupScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  final textInputValueProvider = StateProvider<String>((ref) => '');

  @override
  Widget build(BuildContext context) {
    final invitations =
        ref.watch(kIsWeb ? FirebaseWebHelper.fetchGroupData : fetchGroupData);
    final appointments = ref.watch(kIsWeb
        ? FirebaseWebHelper.fetchSameGroupAttendees
        : fetchSameGroupAttendees);

    final streamGroupChats =
        ref.watch(kIsWeb ? FirebaseWebHelper.streamGroupChat : streamGroupChat);
    final streamIndividualChats = ref.watch(
        kIsWeb ? FirebaseWebHelper.streamIndividualChat : streamIndividualChat);
    final controller = ref.watch(chatControllerProvider);
    var search = ref.watch(textInputValueProvider);

    return Layout(
        child: Column(
      children: [
        Padding(
          padding: MySpacing.x(flexSpacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText.titleMedium(
                "Chat",
                fontSize: 18,
                fontWeight: 600,
              ),
              MyBreadcrumb(
                children: [
                  MyBreadcrumbItem(name: 'Apps'),
                  MyBreadcrumbItem(name: 'Chat', active: true),
                ],
              ),
            ],
          ),
        ),
        MySpacing.height(flexSpacing),
        Padding(
          padding: MySpacing.x(flexSpacing / 2),
          child: Column(
            children: [
              MyFlex(
                children: [
                  MyFlexItem(
                    sizes: "xxl-3 xl-3 md-3",
                    child: MyCard(
                      shadow: MyShadow(elevation: 0.5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              MyContainer.rounded(
                                paddingAll: 0,
                                height: 44,
                                width: 44,
                                child: (userData!.photoUrl != '')
                                    ? Image.network(userData!.photoUrl)
                                    : Image.asset(
                                        Images.avatars[3],
                                      ),
                              ),
                              MySpacing.width(12),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MyText.labelLarge(
                                      userData != null
                                          ? userData!.names.split(" ")[0]
                                          : "",
                                      fontWeight: 600,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        MyContainer.rounded(
                                          paddingAll: 4,
                                          color: contentTheme.success,
                                          clipBehavior:
                                              Clip.antiAliasWithSaveLayer,
                                        ),
                                        MySpacing.width(4),
                                        MyText.bodyMedium(
                                          "Online",
                                          fontSize: 12,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              MySpacing.width(16),
                              MySpacing.height(22),
                              MyContainer.none(
                                paddingAll: 8,
                                borderRadiusAll: 5,
                                child: PopupMenuButton(
                                  offset: const Offset(-165, 10),
                                  position: PopupMenuPosition.under,
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem(
                                        padding: MySpacing.xy(16, 8),
                                        height: 10,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              LucideIcons.users,
                                              size: 16,
                                            ),
                                            MySpacing.width(8),
                                            MyText.bodySmall("New Group")
                                          ],
                                        )),
                                    PopupMenuItem(
                                        padding: MySpacing.xy(16, 8),
                                        height: 10,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              LucideIcons.contact,
                                              size: 16,
                                            ),
                                            MySpacing.width(8),
                                            MyText.bodySmall("Contacts")
                                          ],
                                        )),
                                    PopupMenuItem(
                                        padding: MySpacing.xy(16, 8),
                                        height: 10,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              LucideIcons.bookmark,
                                              size: 16,
                                            ),
                                            MySpacing.width(8),
                                            MyText.bodySmall("Save Message")
                                          ],
                                        )),
                                    PopupMenuItem(
                                        padding: MySpacing.xy(16, 8),
                                        height: 10,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              LucideIcons.userPlus,
                                              size: 16,
                                            ),
                                            MySpacing.width(8),
                                            MyText.bodySmall("Invite Friends")
                                          ],
                                        )),
                                    PopupMenuItem(
                                        padding: MySpacing.xy(16, 8),
                                        height: 10,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              LucideIcons.helpCircle,
                                              size: 16,
                                            ),
                                            MySpacing.width(8),
                                            MyText.bodySmall("Help")
                                          ],
                                        )),
                                    PopupMenuItem(
                                        padding: MySpacing.xy(16, 8),
                                        height: 10,
                                        child: Row(
                                          children: [
                                            const Icon(
                                              LucideIcons.settings,
                                              size: 16,
                                            ),
                                            MySpacing.width(8),
                                            MyText.bodySmall("Setting")
                                          ],
                                        ))
                                  ],
                                  child: const Icon(
                                    LucideIcons.moreVertical,
                                    size: 18,
                                  ),
                                ),
                              )
                            ],
                          ),
                          MySpacing.height(16),
                          TextField(
                            onTap: () {},
                            keyboardType: TextInputType.text,
                            onChanged: (value) {
                              ref.read(textInputValueProvider.state).state =
                                  value;
                            },
                            decoration: InputDecoration(
                              filled: true,
                              prefixIcon: const Icon(
                                LucideIcons.search,
                                size: 20,
                              ),
                              hintText: "People, Groups & Messages...",
                              border: const OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: MySpacing.all(16),
                            ),
                          ),
                          MySpacing.height(20),
                          MyText.titleMedium(
                            "Group",
                            color: contentTheme.title,
                            muted: true,
                            fontWeight: 600,
                          ),
                          MySpacing.height(20),
                          SizedBox(
                            height: 240,
                            child: ListView(
                              // controller: _scrollController,
                              children: invitations.whenData((value) {
                                return search == ''
                                    ? value.map((e) {
                                        return SingleGroup(
                                          data: e,
                                          onTap: () {
                                            if (kIsWeb ||
                                                Platform.isWindows ||
                                                Platform.isMacOS ||
                                                Platform.isLinux) {
                                              controller.setCurrentSelectGroup(
                                                  e.appointmentId!);
                                            } else {
                                              controller.setCurrentSelectGroup(
                                                  e.appointmentId!);
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return MobileChat(
                                                  type: "group",
                                                  currentGroup: e.appointmentId,
                                                );
                                              }));
                                            }
                                          },
                                          name: e.appointmentInfo!.subject!,
                                        );
                                      }).toList()
                                    : value
                                        .where((element) => element
                                            .appointmentInfo!.subject!
                                            .toLowerCase()
                                            .contains(search.toLowerCase()))
                                        .map((e) {
                                        return SingleGroup(
                                          data: e,
                                          onTap: () {
                                            if (kIsWeb ||
                                                Platform.isWindows ||
                                                Platform.isMacOS ||
                                                Platform.isLinux) {
                                              controller.setCurrentSelectGroup(
                                                  e.appointmentId!);
                                            } else {
                                              controller.setCurrentSelectGroup(
                                                  e.appointmentId!);
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return MobileChat(
                                                  type: "group",
                                                  currentGroup: e.appointmentId,
                                                );
                                              }));
                                            }
                                          },
                                          name: e.appointmentInfo!.subject!,
                                        );
                                      }).toList();
                              }).when(
                                data: (List<SingleGroup> value) {
                                  return value;
                                },
                                loading: () {
                                  return [
                                    Center(child: CircularProgressIndicator())
                                  ];
                                },
                                error: (error, stackTrace) {
                                  return [
                                    Center(
                                        child:
                                            Text('Error: ${error.toString()}'))
                                  ];
                                },
                              ),
                            ),
                          ),
                          MyText.titleMedium(
                            "Contact",
                            color: contentTheme.title,
                            muted: true,
                            fontWeight: 600,
                          ),
                          MySpacing.height(20),
                          SizedBox(
                            height: 230,
                            child: ListView(
                              children:
                                  appointments.when(error: (error, stackTrace) {
                                return [
                                  Center(
                                      child: Text('Error: ${error.toString()}'))
                                ];
                              }, loading: () {
                                return [
                                  const Center(
                                      child: CircularProgressIndicator())
                                ];
                              }, data: (snapshot) {
                                return search == ''
                                    ? snapshot.map((e) {
                                        return InvidualUserChat(
                                          attendee: e,
                                          onSelected: () {
                                            if (kIsWeb ||
                                                Platform.isWindows ||
                                                Platform.isMacOS ||
                                                Platform.isLinux) {
                                              controller
                                                  .setCurrentSelectGroup('');
                                              controller
                                                  .setCurrentSelectedUser({
                                                "userId": e.userId,
                                                "name": "${e.names}",
                                                "email": "${e.email}"
                                              });
                                            } else {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return MobileChat(
                                                  type: "chat",
                                                  currentUser: e.userId,
                                                );
                                              }));
                                            }
                                          },
                                        );
                                      }).toList()
                                    : snapshot
                                        .where((element) => element.names!
                                            .toLowerCase()
                                            .contains(search.toLowerCase()))
                                        .map((e) {
                                        return InvidualUserChat(
                                          attendee: e,
                                          onSelected: () {
                                            if (kIsWeb ||
                                                Platform.isWindows ||
                                                Platform.isMacOS ||
                                                Platform.isLinux) {
                                              controller
                                                  .setCurrentSelectedUser({
                                                "userId": e.userId,
                                                "name": "${e.names}",
                                                "email": "${e.email}"
                                              });
                                            } else {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) {
                                                return MobileChat(
                                                  type: "chat",
                                                  currentUser: e.userId,
                                                );
                                              }));
                                            }
                                          },
                                        );
                                      }).toList();
                              }),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  if (kIsWeb ||
                      Platform.isWindows ||
                      Platform.isMacOS ||
                      Platform.isLinux)
                    MyFlexItem(
                      sizes: "xxl-6 xl-6 md-6",
                      child: MyCard(
                        shadow: MyShadow(elevation: 0.5),
                        child: Column(
                          children: [
                            if (controller.currentSelectedUser.isNotEmpty)
                              SizedBox(
                                height: 400,
                                child: ListView(
                                  controller: scrollController,
                                  children:
                                      streamIndividualChats.whenData((value) {
                                    return value
                                        .where((element) =>
                                            element.chatId ==
                                                controller.currentSelectedUser[
                                                        'userId'] +
                                                    "_" +
                                                    userData!.userId ||
                                            element.chatId ==
                                                "${userData!.userId}_" +
                                                    controller
                                                            .currentSelectedUser[
                                                        'userId'])
                                        .toList()
                                        .map((e) {
                                      return SingleChat(message: e);
                                    }).toList();
                                  }).when(data: (List<SingleChat> data) {
                                    return data;
                                  }, error: (error, stackTrace) {
                                    return [
                                      Center(
                                          child: Text(
                                              'Error: ${error.toString()}'))
                                    ];
                                  }, loading: () {
                                    return [
                                      const Center(
                                          child: CircularProgressIndicator())
                                    ];
                                  }),
                                ),
                              ),
                            if (controller.currentSelectedUser.isEmpty)
                              //  messages(),
                              SizedBox(
                                height: 400,
                                child: ListView(
                                  controller: groupScrollController,
                                  children: streamGroupChats.whenData((value) {
                                    return value
                                        .where((element) =>
                                            element.groubId ==
                                            controller.currentSelectedGroup)
                                        .toList()
                                        .map((e) => SingleIndividual(value: e))
                                        .toList();
                                  }).when(data: (List<SingleIndividual> data) {
                                    return data;
                                  }, error: (error, stackTrace) {
                                    return [
                                      Center(
                                          child: Text(
                                              'Error: ${error.toString()}'))
                                    ];
                                  }, loading: () {
                                    return [
                                      const Center(
                                          child: CircularProgressIndicator())
                                    ];
                                  }),
                                ),
                              ),
                            MySpacing.height(8),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: MyContainer(
                                color: contentTheme.primary.withAlpha(20),
                                child: Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.photo),
                                      onPressed: () => controller.getImage(
                                          controller.currentSelectedUser
                                                  .isNotEmpty
                                              ? controller
                                                  .currentSelectedUser['userId']
                                              : controller
                                                  .currentSelectedGroup),
                                    ),
                                    if (controller
                                            .currentSelectedUser.isNotEmpty ||
                                        controller
                                            .currentSelectedGroup.isNotEmpty)
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                              controller.messageController,
                                          autocorrect: false,
                                          style: MyTextStyle.bodySmall(),
                                          decoration: InputDecoration(
                                            hintText: "Type message here",
                                            hintStyle: MyTextStyle.bodySmall(
                                                xMuted: true),
                                            border: outlineInputBorder,
                                            enabledBorder: outlineInputBorder,
                                            focusedBorder: focusedInputBorder,
                                            contentPadding:
                                                MySpacing.xy(16, 16),
                                            isCollapsed: true,
                                          ),
                                        ),
                                      ),
                                    MySpacing.width(16),
                                    if (controller.isLoading)
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    if (!controller.isLoading)
                                      InkWell(
                                        onTap: () async {
                                          if (controller.currentSelectedUser[
                                                  'userId'] !=
                                              null) {
                                            await controller
                                                .sendIndividualMessage(controller
                                                        .currentSelectedUser[
                                                    'userId']);
                                            scrollToBottom("individual");
                                          } else {
                                            controller
                                                .sendMessage()
                                                .then((value) {
                                              scrollToBottom("group");
                                            });
                                          }
                                        },
                                        child: const Icon(
                                          LucideIcons.send,
                                          size: 20,
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (kIsWeb ||
                      Platform.isWindows ||
                      Platform.isMacOS ||
                      Platform.isLinux)
                    MyFlexItem(
                      sizes: "xxl-3 xl-3 md-3",
                      child: MyFlex(
                        contentPadding: false,
                        children: [
                          MyFlexItem(
                            child: MyCard(
                              shadow: MyShadow(elevation: 0.5),
                              borderRadiusAll: 4,
                              paddingAll: 0,
                              child: Stack(
                                children: [
                                  Container(
                                    height: 100,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(4),
                                          topLeft: Radius.circular(4)),
                                      gradient: LinearGradient(colors: [
                                        Color(0xff8360c3),
                                        Color(0xff6a82fb),
                                        Color(0xff00b4db),
                                      ], tileMode: TileMode.clamp),
                                    ),
                                  ),
                                  Padding(
                                    padding: MySpacing.xy(16, 44),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        MyContainer.rounded(
                                          paddingAll: 4,
                                          child: MyContainer.rounded(
                                            paddingAll: 0,
                                            height: 100,
                                            clipBehavior:
                                                Clip.antiAliasWithSaveLayer,
                                            child: (userData!.photoUrl != '')
                                                ? Image.network(
                                                    userData!.photoUrl)
                                                : Image.asset(
                                                    Images.avatars[3],
                                                  ),
                                          ),
                                        ),
                                        MySpacing.height(8),
                                        MyText.bodyLarge(
                                          userData != null
                                              ? userData!.names
                                              : "",
                                          fontSize: 20,
                                          fontWeight: 600,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        MySpacing.height(8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(LucideIcons.mail,
                                                size: 20),
                                            MySpacing.width(8),
                                            MyText.bodyMedium(
                                                userData != null
                                                    ? userData!.email
                                                    : "",
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: 600),
                                          ],
                                        ),
                                        MySpacing.height(16),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const MyContainer.roundBordered(
                                              color: Colors.grey,
                                              paddingAll: 1,
                                            ),
                                            MySpacing.width(8),
                                            MyText.bodyMedium(
                                              userData != null
                                                  ? userData!.role
                                                  : "",
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.center,
                                            )
                                          ],
                                        ),
                                        MySpacing.height(16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            MyButton(
                                              onPressed: () {},
                                              elevation: 0,
                                              padding: MySpacing.xy(12, 16),
                                              backgroundColor:
                                                  contentTheme.primary,
                                              borderRadiusAll:
                                                  AppStyle.buttonRadius.medium,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(LucideIcons.share2,
                                                      color: contentTheme.light,
                                                      size: 16),
                                                  MySpacing.width(8),
                                                  MyText.bodySmall(
                                                    'Share Profile',
                                                    color:
                                                        contentTheme.onPrimary,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    ));
  }

  Widget buildAttachedFile(String fileName, dynamic mb) {
    return MyDottedLine(
      height: 50,
      dottedLength: 1,
      color: Colors.grey.shade400,
      child: Padding(
        padding: MySpacing.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyContainer(
              paddingAll: 4,
              height: 32,
              width: 32,
              // color: contentTheme.warning,
              child: Icon(
                LucideIcons.folderArchive,
                size: 20,
              ),
            ),
            MySpacing.width(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText.bodyMedium(
                    fileName,
                    fontWeight: 600,
                    muted: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                  MyText.bodyMedium(
                    Utils.getStorageStringFromByte(mb),
                  ),
                ],
              ),
            ),
            IconButton(
              padding: MySpacing.zero,
              onPressed: () {},
              icon: const Icon(
                LucideIcons.download,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileDetail(IconData icons, String title, String subTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icons,
              size: 16,
            ),
            MySpacing.width(8),
            MyText.bodyMedium(
              title,
              fontWeight: 600,
            )
          ],
        ),
        MyText.bodyMedium(
          subTitle,
          fontWeight: 600,
        )
      ],
    );
  }
}

class SingleGroup extends StatelessWidget {
  final ChatInvitation data;
  final String name;
  final Function() onTap;
  const SingleGroup(
      {super.key, required this.data, required this.onTap, required this.name});

  @override
  Widget build(BuildContext context) {
    var appointmentInfo = data.appointmentInfo;
    DateTime startDate = appointmentInfo!.startTime!;
    DateTime endDate = appointmentInfo.endTime!;
    return Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
      final controller = ref.watch(chatControllerProvider);
      return MyButton(
        onPressed: onTap,
        elevation: 0,
        borderRadiusAll: 8,
        backgroundColor: controller.currentSelectedGroup == data.appointmentId
            ? theme.colorScheme.primary.withOpacity(0.2)
            : theme.colorScheme.background.withAlpha(5),
        splashColor: theme.colorScheme.onBackground.withAlpha(10),
        child: SizedBox(
          height: 60,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyText.labelLarge(
                      name,
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
      );
    });
  }
}
