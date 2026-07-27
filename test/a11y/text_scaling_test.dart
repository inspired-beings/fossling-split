import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:split/screens/groups_screen.dart';

import '../helpers/pump_localized.dart';

/// Android's font-size setting goes to 2.0x — the UI must survive it on the smallest
/// screen we support. Layout overflow reports fail the test on their own; the
/// expectations below additionally pin that the content is still reachable rather
/// than merely not crashing.
void main() {
  const smallScreen = Size(320, 568);
  const scalers = [1.0, 1.3, 2.0];

  for (final scale in scalers) {
    testWidgets('groups screen survives a ${scale}x font scale', (tester) async {
      tester.view.physicalSize = smallScreen;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpLocalized(
        tester,
        const GroupsScreen(),
        textScaler: TextScaler.linear(scale),
      );

      expect(find.text('No groups yet'), findsOneWidget);
    });
  }
}
