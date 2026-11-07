import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:htrack26/main.dart';

void main() {
  testWidgets('Htrack26 app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const HTrackApp(
        home: Scaffold(
          body: Text('Htrack26'),
        ),
      ),
    );

    expect(find.text('Htrack26'), findsOneWidget);
  });
}