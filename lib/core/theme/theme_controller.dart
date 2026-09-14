import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  const ThemePreferences({this.mode = ThemeMode.light, this.lang = 'en'});

  final ThemeMode mode;
  final String lang;

  String get modeValue => mode == ThemeMode.dark ? 'dark' : 'light';

  ThemePreferences copyWith({ThemeMode? mode, String? lang}) {
    return ThemePreferences(mode: mode ?? this.mode, lang: lang ?? this.lang);
  }
}

class ThemeController extends ValueNotifier<ThemePreferences> {
  ThemeController(this._prefs)
      : super(ThemePreferences(
          mode: _prefs.getString(AppConstants.modeKey) == 'dark'
              ? ThemeMode.dark
              : ThemeMode.light,
          lang: _prefs.getString(AppConstants.langKey) ?? 'en',
        ));

  final SharedPreferences _prefs;

  ThemeMode get mode => value.mode;
  String get lang => value.lang;
  bool get isDark => value.mode == ThemeMode.dark;

  void apply({ThemeMode? mode, String? lang}) {
    final next = value.copyWith(mode: mode, lang: lang);
    if (next == value) return;
    if (mode != null) {
      _prefs.setString(AppConstants.modeKey, next.modeValue);
    }
    if (lang != null) {
      _prefs.setString(AppConstants.langKey, lang);
    }
    value = next;
  }

  void applyFromPreferences({String? mode, String? lang}) {
    apply(
      mode: mode == 'dark' ? ThemeMode.dark : (mode == 'light' ? ThemeMode.light : null),
      lang: lang,
    );
  }
}