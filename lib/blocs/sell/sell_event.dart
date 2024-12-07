import '../../models/sell.dart';

abstract class SellEvent {}

class AddSellEvent extends SellEvent {
  final Sell sell;

  AddSellEvent(this.sell);
}

class FetchSellsEvent extends SellEvent {}
