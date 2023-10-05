import 'package:barrani/data/providers/auth/authentication_provider.dart';
import 'package:barrani/helpers/extensions/string.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/helpers/theme/app_theme.dart';
import 'package:barrani/helpers/utils/ui_mixins.dart';
import 'package:barrani/helpers/widgets/my_button.dart';
import 'package:barrani/helpers/widgets/my_flex.dart';
import 'package:barrani/helpers/widgets/my_flex_item.dart';
import 'package:barrani/helpers/widgets/my_responsiv.dart';
import 'package:barrani/helpers/widgets/my_spacing.dart';
import 'package:barrani/helpers/widgets/my_text.dart';
import 'package:barrani/helpers/widgets/my_text_style.dart';
import 'package:barrani/helpers/widgets/responsive.dart';
import 'package:barrani/images.dart';
import 'package:barrani/views/layouts/auth_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class Register extends ConsumerStatefulWidget {
  static const routeName = '/auth/register';

  const Register({Key? key}) : super(key: key);

  @override
  ConsumerState<Register> createState() => _RegisterState();
}

class _RegisterState extends ConsumerState<Register>
    with SingleTickerProviderStateMixin, UIMixin {
  GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _invitationCodeController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var authenticationProvider = ref.read(authProvider);

    return AuthLayout(
      child: Padding(
        padding: MySpacing.all(16),
        child: MyFlex(
          contentPadding: false,
          children: [
            MyFlexItem(
              sizes: "lg-6",
              child: MyResponsive(builder: (_, __, type) {
                return type == MyScreenMediaType.xxl
                    ? Image.asset(
                        Images.login[2],
                        fit: BoxFit.cover,
                        height: 500,
                      )
                    : type == MyScreenMediaType.xl
                        ? Image.asset(
                            Images.login[2],
                            fit: BoxFit.cover,
                            height: 500,
                          )
                        : type == MyScreenMediaType.lg
                            ? Image.asset(
                                Images.login[2],
                                fit: BoxFit.cover,
                                height: 500,
                              )
                            : const SizedBox();
              }),
            ),
            MyFlexItem(
              sizes: "lg-6",
              child: Padding(
                padding: MySpacing.y(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: MyText.titleLarge(
                        "register".tr(),
                        fontWeight: 700,
                      )),
                      MySpacing.height(10),
                      Center(
                          child: MyText.bodySmall(
                        "don't_have_an_account?_create_your_\naccount,_it_takes_less_than_a_minute"
                            .tr(),
                        muted: true,
                      )),
                      MySpacing.height(45),
                      MyText.labelMedium(
                        "invitation_code".tr().capitalizeWords,
                      ),
                      MySpacing.height(4),
                      TextFormField(
                        controller: _invitationCodeController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          if (authenticationProvider.isSubmitted) {
                            ref
                                .read(authProvider.notifier)
                                .validateInvitation(value);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Invitation Code",
                          labelStyle: MyTextStyle.bodySmall(xMuted: true),
                          border: outlineInputBorder,
                          prefixIcon: const Icon(
                            Icons.insert_invitation_outlined,
                            size: 20,
                          ),
                          contentPadding: MySpacing.all(16),
                          isCollapsed: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                      ),
                      if (authenticationProvider.errors.isNotEmpty &&
                          authenticationProvider
                                  .errors['invitation_code_error'] !=
                              null)
                        MyText.bodyMedium(
                          authenticationProvider
                              .errors['invitation_code_error']!,
                          color: Colors.red,
                        ),
                      MySpacing.height(16),
                      MyText.labelMedium(
                        "email_address".tr().capitalizeWords,
                      ),
                      MySpacing.height(4),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          if (authenticationProvider.isSubmitted) {
                            ref
                                .read(authProvider.notifier)
                                .validateEmail(value);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          labelStyle: MyTextStyle.bodySmall(xMuted: true),
                          border: outlineInputBorder,
                          prefixIcon: const Icon(
                            LucideIcons.mail,
                            size: 20,
                          ),
                          contentPadding: MySpacing.all(16),
                          isCollapsed: true,
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                        ),
                      ),
                      if (authenticationProvider.errors.isNotEmpty &&
                          authenticationProvider.errors['email_error'] != null)
                        MyText.bodyMedium(
                          authenticationProvider.errors['email_error']!,
                          color: Colors.red,
                        ),
                      MySpacing.height(16),
                      MyText.labelMedium(
                        "email_password".tr().capitalizeWords,
                      ),
                      MySpacing.height(4),
                      TextFormField(
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: !ref.watch(authProvider).showPassword,
                        onChanged: (value) {
                          if (authenticationProvider.isSubmitted) {
                            ref
                                .read(authProvider.notifier)
                                .validatePassword(value);
                          }
                        },
                        decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: MyTextStyle.bodySmall(xMuted: true),
                            border: outlineInputBorder,
                            prefixIcon: const Icon(
                              LucideIcons.lock,
                              size: 20,
                            ),
                            suffixIcon: InkWell(
                              onTap: ref
                                  .read(authProvider.notifier)
                                  .onChangeShowPassword,
                              child: Icon(
                                authenticationProvider.showPassword
                                    ? LucideIcons.eye
                                    : LucideIcons.eyeOff,
                                size: 20,
                              ),
                            ),
                            contentPadding: MySpacing.all(16),
                            isCollapsed: true,
                            floatingLabelBehavior: FloatingLabelBehavior.never),
                      ),
                      if (authenticationProvider.errors.isNotEmpty &&
                          authenticationProvider.errors['password_error'] !=
                              null)
                        MyText.bodyMedium(
                          authenticationProvider.errors['password_error']!,
                          color: Colors.red,
                        ),
                      MySpacing.height(16),
                      if (authenticationProvider.errors.isNotEmpty &&
                          authenticationProvider.errors['error'] != null)
                        Center(
                          child: MyText.bodyMedium(
                            authenticationProvider.errors['error']!,
                            color: Colors.red,
                          ),
                        ),
                      MySpacing.height(16),
                      Center(
                        child: MyButton.rounded(
                          onPressed: () {
                            ref.read(authProvider.notifier).onRegister(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                  invitationCode:
                                      _invitationCodeController.text,
                                );
                          },
                          elevation: 0,
                          padding: MySpacing.xy(20, 16),
                          backgroundColor: contentTheme.primary,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ref.watch(authProvider).loading
                                  ? SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(
                                        color: theme.colorScheme.onPrimary,
                                        strokeWidth: 1.2,
                                      ),
                                    )
                                  : Container(),
                              if (ref.watch(authProvider).loading)
                                MySpacing.width(16),
                              MyText.bodySmall(
                                'register'.tr(),
                                color: contentTheme.onPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                        child: MyButton.text(
                          onPressed: () {
                            ref.read(authProvider.notifier).state =
                                ref.read(authProvider.notifier).state.copyWith(
                              errors: {},
                            );
                            NavigatorHelper.pushNamed('/auth/login');
                          },
                          elevation: 0,
                          padding: MySpacing.x(16),
                          splashColor: contentTheme.secondary.withOpacity(0.1),
                          child: MyText.labelMedium(
                            'already_have_account_?'.tr(),
                            color: contentTheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
