import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/screens/groups_screen.dart';

import '../helpers/pump_localized.dart';

/// Every state the user can land on, in every shipped locale, must pass the Material
/// accessibility guidelines. A new screen that is not registered here is the failure
/// this suite exists to prevent — keep the map exhaustive.
final _screenStates = <String, Future<void> Function(WidgetTester, Locale)>{
  'groups (empty)': (tester, locale) =>
      pumpLocalized(tester, const GroupsScreen(), locale: locale),
};

void main() {
  for (final locale in const [Locale('en'), Locale('fr')]) {
    for (final state in _screenStates.entries) {
      testWidgets('${state.key} (${locale.languageCode}) meets a11y guidelines',
          (tester) async {
        final handle = tester.ensureSemantics();
        await state.value(tester, locale);

        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));

        handle.dispose();
      });
    }
  }
}
