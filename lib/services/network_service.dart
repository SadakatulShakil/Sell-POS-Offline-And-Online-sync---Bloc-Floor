import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Stream<bool> onNetworkChange;

  NetworkService() : onNetworkChange = Connectivity().onConnectivityChanged.map((result) {
    return result != ConnectivityResult.none; // Return true if connected, false if disconnected
  });
}
