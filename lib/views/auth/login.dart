import 'package:barrani/data/providers/auth/authentication_provider.dart';
import 'package:barrani/helpers/extensions/string.dart';
import 'package:barrani/helpers/firebase/auth.dart';
import 'package:barrani/helpers/navigator_helper.dart';
import 'package:barrani/helpers/services/auth_services.dart';
import 'package:barrani/helpers/services/web_auth_services.dart';
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
import 'package:barrani/views/dashboard.dart';
import 'package:barrani/views/layouts/auth_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginPage extends ConsumerStatefulWidget {
  static const routeName = '/auth/login';

  const LoginPage({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin, UIMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey();

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
            child: MyResponsive(
              builder: (_, __, type) {
                return type == MyScreenMediaType.xxl
                    ? Image.asset(
                        Images.login[3],
                        fit: BoxFit.cover,
                        height: 500,
                      )
                    : type == MyScreenMediaType.xl
                        ? Image.asset(
                            Images.login[3],
                            fit: BoxFit.cover,
                            height: 500,
                          )
                        : type == MyScreenMediaType.lg
                            ? Image.asset(
                                Images.login[3],
                                fit: BoxFit.cover,
                                height: 500,
                              )
                            : const SizedBox();
              },
            ),
          ),
          MyFlexItem(
            sizes: "lg-6",
            child: Padding(
              padding: MySpacing.y(28),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: MyText.titleLarge(
                        "Welcome",
                        fontWeight: 600,
                        fontSize: 24,
                      ),
                    ),
                    Center(
                      child: MyText.bodyMedium(
                        "Login your account",
                        fontSize: 16,
                      ),
                    ),
                    MySpacing.height(40),
                    MyText.bodyMedium(
                      "Your Email",
                    ),
                    MySpacing.height(8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        if (authenticationProvider.isSubmitted) {
                          ref.read(authProvider.notifier).validateEmail(value);
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
                    if (authenticationProvider.isSubmitted &&
                        authenticationProvider.errors.isNotEmpty &&
                        authenticationProvider.errors['email_error'] != null)
                      MyText.bodyMedium(
                        authenticationProvider.errors['email_error']!,
                        color: Colors.red,
                      ),
                    MySpacing.height(16),
                    MyText.labelMedium(
                      "password".tr(),
                    ),
                    MySpacing.height(8),
                    TextFormField(
                      validator: authenticationProvider.basicValidator
                          .getValidation('password'),
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !authenticationProvider.showPassword,
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
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                      ),
                    ),
                    if (authenticationProvider.isSubmitted &&
                        authenticationProvider.errors.isNotEmpty &&
                        authenticationProvider.errors['password_error'] != null)
                      MyText.bodyMedium(
                        authenticationProvider.errors['password_error']!,
                        color: Colors.red,
                      ),
                    MySpacing.height(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => ref
                              .read(authProvider.notifier)
                              .onChangeCheckBox(
                                  !authenticationProvider.isChecked),
                          child: Row(
                            children: [
                              Checkbox(
                                onChanged: ref
                                    .read(authProvider.notifier)
                                    .onChangeCheckBox,
                                value: authenticationProvider.isChecked,
                                activeColor: theme.colorScheme.primary,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: getCompactDensity,
                              ),
                              MySpacing.width(16),
                              MyText.bodyMedium(
                                "Remember Me",
                              ),
                            ],
                          ),
                        ),
                        MyButton.text(
                          onPressed: ref
                              .read(authProvider.notifier)
                              .goToForgotPassword,
                          elevation: 0,
                          padding: MySpacing.xy(8, 0),
                          splashColor: contentTheme.secondary.withOpacity(0.1),
                          child: MyText.labelSmall(
                            'forgot_password?'.tr().capitalizeWords,
                            color: contentTheme.secondary,
                          ),
                        ),
                      ],
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
                        onPressed: () async {
                          await ref.read(authProvider.notifier).onLogin(
                                email: _emailController.text,
                                password: _passwordController.text,
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
                              'login'.tr(),
                              color: contentTheme.onPrimary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: MyButton.text(
                        onPressed: ref.read(authProvider.notifier).gotoRegister,
                        elevation: 0,
                        padding: MySpacing.x(16),
                        splashColor: contentTheme.secondary.withOpacity(0.1),
                        child: MyText.labelMedium(
                          'Don\'t have account? register'.tr(),
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
    ));
  }
}
