import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../services/network_service.dart';
import 'network_event.dart';
import 'network_state.dart';

class NetworkBloc extends Bloc<NetworkEvent, NetworkState> {
  final NetworkService networkService;

  NetworkBloc(this.networkService) : super(NetworkDisconnected()) {
    // Register event handlers
    on<NetworkConnectedEvent>(_onNetworkConnected);
    on<NetworkDisconnectedEvent>(_onNetworkDisconnected);

    // Listen to network changes
    networkService.onNetworkChange.listen((isConnected) {
      if (isConnected) {
        add(NetworkConnectedEvent());
      } else {
        add(NetworkDisconnectedEvent());
      }
    });
  }

  // Event handler for network connected event
  void _onNetworkConnected(NetworkConnectedEvent event, Emitter<NetworkState> emit) {
    emit(NetworkConnected());
  }

  // Event handler for network disconnected event
  void _onNetworkDisconnected(NetworkDisconnectedEvent event, Emitter<NetworkState> emit) {
    emit(NetworkDisconnected());
  }
}