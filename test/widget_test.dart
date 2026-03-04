import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:neara/main.dart';

void main() {
  testWidgets('Neara app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NearaApp());
    // App should start without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
