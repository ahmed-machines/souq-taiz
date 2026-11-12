import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';

/// Current UI locale. Arabic by default; user can switch to English.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() => AppConstants.defaultLocale;

  void toggle() {
    state = state == AppConstants.arabic
        ? AppConstants.english
        : AppConstants.arabic;
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);
