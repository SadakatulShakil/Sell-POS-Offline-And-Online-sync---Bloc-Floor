import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:point_of_sells/main.dart';
import 'package:point_of_sells/repositories/sell_repositories.dart';
import 'package:point_of_sells/screens/sell_screen.dart';
import 'package:point_of_sells/services/network_service.dart';
import 'package:point_of_sells/database/app_database.dart';

void main() {
  late SellRepository sellRepository;
  late NetworkService networkService;

  setUp(() async {
    // Initialize the local database for testing.
    final database = await $FloorAppDatabase.inMemoryDatabaseBuilder().build();
    sellRepository = SellRepository(database);
    networkService = NetworkService();
  });

  testWidgets('SellScreen initializes and adds a sell item', (WidgetTester tester) async {
    // Build the app with dependencies and trigger a frame.
    await tester.pumpWidget(MyApp(
      sellRepository: sellRepository,
      networkService: networkService,
    ));

    // Verify SellScreen is loaded.
    expect(find.byType(SellScreen), findsOneWidget);

    // Verify the presence of essential widgets.
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.text('POS System'), findsOneWidget);

    // Add a new sell item.
    final productNameField = find.byKey(Key('productNameField')); // Ensure keys are assigned in SellScreen.
    final priceField = find.byKey(Key('priceField'));
    final addButton = find.byIcon(Icons.add);

    // Enter product details and tap the add button.
    await tester.enterText(productNameField, 'Test Product');
    await tester.enterText(priceField, '100');
    await tester.tap(addButton);

    // Rebuild the widget after the state has changed.
    await tester.pump();

    // Verify that the new sell item is added to the list.
    expect(find.text('Test Product'), findsOneWidget);
    expect(find.text('Quantity: 1'), findsOneWidget);
  });
}
