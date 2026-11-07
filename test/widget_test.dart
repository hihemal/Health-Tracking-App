
import 'package:flutter_test/flutter_test.dart';
import 'package:htrack26/main.dart';

void main() {
  testWidgets('Htrack26 app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const HTrackApp());

    expect(find.text('Htrack26'), findsOneWidget);
  });
}
