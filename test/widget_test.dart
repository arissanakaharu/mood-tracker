import 'package:flutter_test/flutter_test.dart';
import 'package:mood_tracker_app/main.dart' ;

void main() {
  testWidgets('HomePage menampilkan sapaan', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.textContaining('Halo'), findsOneWidget);
  });
}