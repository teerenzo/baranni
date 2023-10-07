import 'dart:convert';

import 'package:barrani/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barrani/helpers/localizations/language.dart';
import 'package:barrani/helpers/services/auth_services.dart';
import 'package:barrani/helpers/theme/theme_customizer.dart';

class LocalStorage {
  static const String _loggedInUserKey = "user";
  static const String _loggedInUserData = "userData";
  static const String _themeCustomizerKey = "theme_customizer";
  static const String _languageKey = "lang_code";
  static const String _themeKey = "themeKey";

  static SharedPreferences? _preferencesInstance;

  static SharedPreferences get preferences {
    if (_preferencesInstance == null) {
      throw ("Call LocalStorage.init() to initialize local storage");
    }
    return _preferencesInstance!;
  }

  static Future<void> init() async {
    _preferencesInstance = await SharedPreferences.getInstance();
    await initData();
  }

  static Future<void> initData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    AuthService.isLoggedIn = preferences.getBool(_loggedInUserKey) ?? false;
    ThemeCustomizer.fromJSON(preferences.getString(_themeCustomizerKey));
  }

  static Future<bool> setLoggedInUser(bool loggedIn) async {
    return preferences.setBool(_loggedInUserKey, loggedIn);
  }

  static Future<bool> isLoggedIn() async {
    return preferences.getBool(_loggedInUserKey) ?? false;
  }

  static Future<bool> setCustomizer(ThemeCustomizer themeCustomizer) {
    return preferences.setString(_themeCustomizerKey, themeCustomizer.toJSON());
  }

  static Future<bool> setLanguage(Language language) {
    return preferences.setString(_languageKey, language.locale.languageCode);
  }

  static String? getLanguage() {
    return preferences.getString(_languageKey);
  }

  static Future<bool> removeLoggedInUser() async {
    return preferences.remove(_loggedInUserKey);
  }

  static Future<void> storeUserdata(UserModal userData) async {
    await preferences.setString(
        _loggedInUserData, jsonEncode(userData.toJSON()));
  }

  static UserModal? getLocalUserData() {
    String? userData = preferences.getString(_loggedInUserData);
    if (userData != null) {
      return UserModal.fromJSON(jsonDecode(userData));
    }
    return null;
  }

  static Future<void> removeUserData() async {
    await preferences.remove(_loggedInUserData);
  }

  static Future<void> setAppTheme(value) async {
    await preferences.setBool(_themeKey, value);
  }

  static bool getAppTheme() {
    return preferences.getBool(_themeKey) ?? true;
  }

  static Future<void> setProjectData(String id, name) async {
    await preferences.setString("projectId", id);
    await preferences.setString(id, name);
  }

  static String? getProjectId() {
    return preferences.getString("projectId");
  }

  static String? getProjectName(String id) {
    return preferences.getString(id);
  }

  static Future<void> removeProjectData() async {
    await preferences.remove("projectId");
  }
}
