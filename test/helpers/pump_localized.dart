import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/l10n/generated/app_localizations.dart';
import 'package:split/libs/build_app_theme.dart';

Future<void> pumpLocalized(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return tester.pumpWidget(MaterialApp(
    locale: locale,
    theme: buildAppTheme(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(textScaler: textScaler),
      child: child,
    ),
  ));
}
