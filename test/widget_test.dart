import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:threadly/main.dart';
import 'package:threadly/providers/shop_provider.dart';

void main() {
  testWidgets('App starts', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(create: (_) => ShopProvider(), child: const ThreadlyApp()),
    );
    expect(find.text('threadly'), findsOneWidget);
  });
}
