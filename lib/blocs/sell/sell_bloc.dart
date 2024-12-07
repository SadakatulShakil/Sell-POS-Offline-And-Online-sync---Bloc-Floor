import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/sell_repositories.dart';
import 'sell_event.dart';
import 'sell_state.dart';

class SellBloc extends Bloc<SellEvent, SellState> {
  final SellRepository repository;

  SellBloc(this.repository) : super(SellInitial()) {
    on<AddSellEvent>((event, emit) async {
      emit(SellLoading());
      await repository.addSell(event.sell);
      emit(SellAdded());
    });

    on<FetchSellsEvent>((event, emit) async {
      emit(SellLoading());
      final sells = await repository.getAllSells();
      emit(SellLoaded(sells));
    });
  }
}
