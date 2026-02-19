import 'package:integration_test/integration_test_driver.dart';

/// Integration test driver for web browser integration tests
///
/// https://docs.flutter.dev/testing/integration-tests#test-in-a-web-browser
/// flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart
Future<void> main() => integrationDriver();
