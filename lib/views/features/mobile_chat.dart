import 'package:barrani/controller/features/chat_controller.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/services/chat_services.dart';
import 'package:barrani/helpers/utils/my_shadow.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:barrani/helpers/widgets/my_card.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_flex_item.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text_style.dart';
import 'package:barrani/widgets/SingleChat.dart';
import 'package:barrani/widgets/SingleInvividual.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

// ignore: must_be_immutable
class MobileChat extends ConsumerStatefulWidget {
  String type = "";
  String? currentUser;
  String? currentGroup;
  MobileChat(
      {super.key, required this.type, this.currentGroup, this.currentUser});

  @override
  ConsumerState<MobileChat> createState() => _MobileChatState();
}

class _MobileChatState extends ConsumerState<MobileChat>
    with SingleTickerProviderStateMixin, UIMixin {
  @override
  void initState() {
    super.initState();
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final streamGroupChats = ref.watch(streamGroupChat);
    final streamIndividualChats = ref.watch(streamIndividualChat);
    void _scrollToBottom() {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Chat",
            style: MyTextStyle.bodySmall(),
          ),
        ),
        body: Consumer(builder: (context, watch, child) {
          final controller = ref.watch(chatControllerProvider);
          return MyFlexItem(
            sizes: "xxl-6 xl-6 ",
            child: MyCard(
              shadow: MyShadow(elevation: 0.5),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (widget.type != "group")
                      Container(
                        height: MediaQuery.of(context).size.height / 1.3,
                        child: ListView(
                          controller: _scrollController,
                          children: streamIndividualChats.whenData((value) {
                            return value
                                .where((element) =>
                                    element.chatId ==
                                        widget.currentUser! +
                                            "_" +
                                            userData!.userId ||
                                    element.chatId ==
                                        userData!.userId +
                                            "_" +
                                            widget.currentUser!)
                                .toList()
                                .map((e) {
                              return SingleChat(message: e);
                            }).toList();
                          }).when(data: (List<SingleChat> data) {
                            return data;
                          }, error: (error, stackTrace) {
                            return [
                              Center(child: Text('Error: ${error.toString()}'))
                            ];
                          }, loading: () {
                            return [
                              const Center(child: CircularProgressIndicator())
                            ];
                          }),
                        ),
                      ),
                    if (widget.type == "group")
                      Container(
                        height: MediaQuery.of(context).size.height / 1.35,
                        child: ListView(
                          controller: _scrollController,
                          children: streamGroupChats.whenData((value) {
                            return value
                                .where((element) =>
                                    element.groubId == widget.currentGroup)
                                .toList()
                                .map((e) => SingleIndividual(value: e))
                                .toList();
                          }).when(data: (List<SingleIndividual> data) {
                            return data;
                          }, error: (error, stackTrace) {
                            return [
                              Center(child: Text('Error: ${error.toString()}'))
                            ];
                          }, loading: () {
                            return [
                              const Center(child: CircularProgressIndicator())
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
                                  widget.currentUser != null
                                      ? widget.currentUser!
                                      : widget.currentGroup!),
                            ),
                            if (controller.currentSelectedUser.isNotEmpty ||
                                controller.currentSelectedGroup.isNotEmpty)
                              Expanded(
                                child: TextFormField(
                                  controller: controller.messageController,
                                  autocorrect: false,
                                  style: MyTextStyle.bodySmall(),
                                  decoration: InputDecoration(
                                    hintText: "Type message here",
                                    hintStyle:
                                        MyTextStyle.bodySmall(xMuted: true),
                                    border: outlineInputBorder,
                                    enabledBorder: outlineInputBorder,
                                    focusedBorder: focusedInputBorder,
                                    contentPadding: MySpacing.xy(16, 16),
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
                                  if (widget.currentUser != null) {
                                    await controller.sendIndividualMessage(
                                        widget.currentUser!);
                                    _scrollToBottom();
                                  } else {
                                    controller.sendMessage();
                                    _scrollToBottom();
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
          );
        }));
  }
}
