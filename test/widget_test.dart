import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_kinetic_warehouse_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: WarehouseApp()));

    // Verify that our counters start at 0. (Note: WarehouseApp doesn't have a counter, so this test might need updating later)
    // For now, we just want it to build.
  });
}
