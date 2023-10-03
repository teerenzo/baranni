import 'dart:io';

import 'package:barrani/global_functions.dart';
import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/extensions/extensions.dart';
import 'package:barrani/helpers/theme/admin_theme.dart';
import 'package:barrani/helpers/theme/app_theme.dart';
import 'package:barrani/helpers/utils/utils.dart';
import 'package:barrani/helpers/widgets/my_container.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/images.dart';
import 'package:barrani/models/IndividualChat.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../helpers/theme/app_style.dart';
import '../helpers/widgets/my_button.dart';

// ignore: must_be_immutable
class SingleChat extends StatefulWidget {
  Messages message;
  SingleChat({super.key, required this.message});

  @override
  State<SingleChat> createState() => _SingleChatState();
}

class _SingleChatState extends State<SingleChat> {
  final isLoadingProvider = StateProvider<bool>((ref) => false);
  final isLoadingSpinnerProvider = StateProvider<bool>((ref) => false);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: widget.message.senderId != userData!.userId
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      MyContainer.rounded(
                        height: 32,
                        width: 32,
                        paddingAll: 0,
                        child: Image.asset(
                          Images.avatars[1],
                          fit: BoxFit.cover,
                        ),
                      ),
                      MySpacing.height(4),
                      MyText.bodySmall(
                        '${Utils.getTimeStringFromDateTime(
                          widget.message.timestamp!,
                          showSecond: false,
                        )}',
                        muted: true,
                        fontWeight: 600,
                        fontSize: 8,
                      )
                    ],
                  ),
                  MySpacing.width(12),
                  Wrap(
                    alignment: WrapAlignment.start,
                    children: [
                      if (widget.message.type == "image")
                        GestureDetector(
                          onTap: () {
                            showImageDialog(context, widget.message.message!);
                          },
                          child: Image.network(
                            widget.message.message!,
                            height: 200,
                            width: 200,
                          ),
                        )
                      else
                        MyContainer.none(
                          paddingAll: 8,
                          margin: MySpacing.only(
                              top: 10,
                              right: MediaQuery.of(context).size.width * 0.20),
                          alignment: Alignment.bottomRight,
                          borderRadiusAll: 4,
                          // color: contentTheme.secondary.withAlpha(30),
                          child: MyText.titleMedium(
                            widget.message.message!,
                            fontSize: 12,
                            overflow: TextOverflow.ellipsis,
                            // color: contentTheme.secondary,
                          ),
                        ),
                    ],
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Wrap(
                      alignment: WrapAlignment.end,
                      children: [
                        if (widget.message.type == "image")
                          GestureDetector(
                            onTap: () {
                              showImageDialog(context, widget.message.message!);
                            },
                            child: Image.network(
                              widget.message.message!,
                              height: 200,
                              width: 200,
                            ),
                          )
                        else
                          MyContainer(
                            paddingAll: 8,
                            margin: MySpacing.only(
                              top: 10,
                              left: MediaQuery.of(context).size.width * 0.20,
                            ),
                            color: theme.colorScheme.primary.withAlpha(30),
                            child: MyText.bodyMedium(
                              widget.message.message!,
                              fontSize: 12,
                              fontWeight: 600,
                              // color: contentTheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  MySpacing.width(12),
                  Column(
                    children: [
                      MyContainer.rounded(
                        height: 32,
                        width: 32,
                        paddingAll: 0,
                        child: Image.asset(
                          Images.avatars[8],
                          fit: BoxFit.cover,
                        ),
                      ),
                      MySpacing.height(4),
                      MyText.bodySmall(
                        '${Utils.getTimeStringFromDateTime(
                          widget.message.timestamp!,
                          showSecond: false,
                        )}',
                        fontSize: 8,
                        muted: true,
                        fontWeight: 600,
                      ),
                    ],
                  ),
                ],
              ));
  }

  void showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              final isLoading = ref.watch(isLoadingProvider.state).state;
              final isLoadingSpinner =
                  ref.watch(isLoadingSpinnerProvider.state).state;

              return SizedBox(
                height: (Platform.isIOS || Platform.isAndroid)
                    ? MediaQuery.of(context).size.height / 2
                    : MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(6),
                      width: (Platform.isIOS || Platform.isAndroid)
                          ? MediaQuery.of(context).size.width
                          : MediaQuery.of(context).size.width / 2.5,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              try {
                                ref.read(isLoadingSpinnerProvider.state).state =
                                    true;
                                await downloadImage(imageUrl);
                                ref.read(isLoadingProvider.state).state = true;
                                ref.read(isLoadingSpinnerProvider.state).state =
                                    false;
                              } catch (e) {
                                rethrow;
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: selectedColor.color,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 12.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            icon: isLoadingSpinner
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.0,
                                    ),
                                  )
                                : isLoading
                                    ? Icon(Icons.done)
                                    : Icon(Icons.download),
                            label: Text(isLoading
                                ? 'Done, Check in download folder'
                                : 'Download'),
                          ),
                          if (Platform.isMacOS || Platform.isWindows || kIsWeb)
                            MyButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              elevation: 0,
                              padding: MySpacing.xy(20, 16),
                              borderColor: AdminTheme.theme.contentTheme.danger,
                              backgroundColor: AdminTheme
                                  .theme.contentTheme.danger
                                  .withOpacity(0.12),
                              splashColor: AdminTheme.theme.contentTheme.danger
                                  .withOpacity(0.2),
                              borderRadiusAll: AppStyle.buttonRadius.medium,
                              child: MyText.bodySmall(
                                'Close',
                                color: AdminTheme.theme.contentTheme.danger,
                              ),
                            ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  final ContentThemeColor selectedColor = ContentThemeColor.primary;

  final SnackBarBehavior selectedBehavior = SnackBarBehavior.floating;
}
