import '../../models/sell.dart';

abstract class SellState {}

class SellInitial extends SellState {}

class SellLoading extends SellState {}

class SellLoaded extends SellState {
  final List<Sell> sells;

  SellLoaded(this.sells);
}

class SellAdded extends SellState {}
