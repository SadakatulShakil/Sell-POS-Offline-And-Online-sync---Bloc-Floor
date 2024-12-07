import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:point_of_sells/blocs/sell/sell_bloc.dart';
import '../blocs/network/network_bloc.dart';
import '../blocs/network/network_state.dart';
import '../database/app_database.dart';
import '../models/sell.dart';
import '../main.dart';

class SyncService {
  final AppDatabase database;
  SellBloc sellBloc;

  SyncService(this.database,  this.sellBloc);

  // This will be triggered once to listen for network changes
  void listenToNetworkChanges(BuildContext context) {
    // Listening to network events to trigger syncing
    BlocProvider.of<NetworkBloc>(context).stream.listen((state) {
      if (state is NetworkConnected) {
        // If connected, sync unsynced sells
        syncUnsyncedSells();
      }
    });
  }

  Future<void> syncUnsyncedSells() async {
    final unsyncedSells = await database.sellDao.getUnsyncedSells();

    for (final sell in unsyncedSells) {
      final isSuccessful = await _syncToApi(sell);

      if (isSuccessful) {
        final updatedSell = Sell(
          id: sell.id,
          productName: sell.productName,
          price: sell.price,
          quantity: sell.quantity,
          isSynced: true,
        );

        await database.sellDao.updateSell(updatedSell);
        // Show success snackbar on successful sync
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('${sell.productName} synced successfully!')),
        );
      } else {
        // Show error snackbar if sync fails
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Failed to sync ${sell.productName}')),
        );
      }
    }
  }

  // This simulates an API call for syncing a sell
  Future<bool> _syncToApi(Sell sell) async {
    try {
      final url = Uri.parse('https://www.google.com/'); // Replace with actual API URL
      final response = await http.get(
        url,
        //headers: {'Content-Type': 'application/json'},
        // body: {
        //   'id': sell.id.toString(),
        //   'productName': sell.productName,
        //   'price': sell.price.toString(),
        //   'quantity': sell.quantity.toString(),
        // },
      );
      print("code: "+ response.statusCode.toString());
      return response.statusCode == 200;// Assuming 201 means successful creation

    } catch (e) {
      debugPrint('Sync failed: $e');
      return false;
    }
  }
}
