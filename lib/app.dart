import 'package:flutter/material.dart';

import 'l10n/generated/app_localizations.dart';
import 'libs/build_app_theme.dart';
import 'screens/groups_screen.dart';

class SplitApp extends StatelessWidget {
  const SplitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: buildAppTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const GroupsScreen(),
    );
  }
}
