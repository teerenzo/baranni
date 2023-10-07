import 'package:barrani/global_variables.dart';
import 'package:barrani/helpers/widgets/my_text_style.dart';
import 'package:flutter/material.dart';

import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/app_constant.dart';

class AppTextField extends StatelessWidget {
  final int maxLines;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  AppTextField({
    super.key,
    this.maxLines = 1,
    this.hintText = '',
    this.prefixIcon,
    this.suffixIcon,
  });

  final BoxConstraints iconConstrain = BoxConstraints(
    minWidth: inputIconMinWidth,
    maxWidth: inputIconMaxWidth,
    minHeight: inputIconMaxHeight,
    maxHeight: inputIconMaxHeight,
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: 1,
      style: MyTextStyle.bodyMedium(),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: MyTextStyle.bodySmall(xMuted: true),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: theme.colorScheme.primary),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(
              width: 1,
              strokeAlign: 0,
              color: theme.colorScheme.onBackground.withAlpha(80)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
          borderSide: BorderSide(width: 1, color: theme.colorScheme.primary),
        ),
        prefixIcon: prefixIcon,
        suffix: suffixIcon,
        prefixIconConstraints: iconConstrain,
        suffixIconConstraints: iconConstrain,
        contentPadding: MySpacing.xy(inputXPadding, inputYPadding),
        isCollapsed: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
      ),
    );
  }
}
