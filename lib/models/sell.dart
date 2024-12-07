import 'package:floor/floor.dart';

@entity
class Sell {
  @primaryKey
  final int id;
  final String productName;
  final double price;
  final int quantity;
  final bool isSynced;

  Sell({
    required this.id,
    required this.productName,
    required this.price,
    required this.quantity,
    this.isSynced = false,
  });
}
