// Integration tests run in a full Flutter application, so they exercise the
// real Android/iOS implementation of the plugin.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:flutter_secure_guard/flutter_secure_guard.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('device.check returns a report', (WidgetTester tester) async {
    final report = await FlutterGuard.device.check();
    // Results depend on the device running the test, so only check that a
    // report came back.
    expect(report, isNotNull);
  });
}
