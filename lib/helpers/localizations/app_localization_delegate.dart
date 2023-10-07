import 'package:flutter/material.dart';
import 'package:barrani/helpers/localizations/language.dart';

class AppLocalizationsDelegate extends LocalizationsDelegate {
  final BuildContext context;

  const AppLocalizationsDelegate(this.context);

  @override
  bool isSupported(Locale locale) =>
      Language.getLanguagesCodes().contains(locale.languageCode);

  @override
  Future load(Locale locale) => _load(locale);

  Future _load(Locale locale) async {
    return;
  }

  @override
  bool shouldReload(LocalizationsDelegate old) => false;
}
