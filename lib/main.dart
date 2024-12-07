import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:point_of_sells/repositories/sell_repositories.dart';
import 'package:point_of_sells/screens/sell_screen.dart';
import 'package:point_of_sells/services/network_service.dart';
import 'package:point_of_sells/services/sync_service.dart';

import 'blocs/network/network_bloc.dart';
import 'blocs/sell/sell_bloc.dart';
import 'blocs/sell/sell_event.dart';
import 'database/app_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  final sellRepository = SellRepository(database);
  final networkService = NetworkService();

  runApp(MyApp(sellRepository: sellRepository, networkService: networkService));
}

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  final SellRepository sellRepository;
  final NetworkService networkService;

  MyApp({required this.sellRepository, required this.networkService});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SellBloc(sellRepository)..add(FetchSellsEvent()),
        ),
        BlocProvider(
          create: (context) => NetworkBloc(networkService),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Listen for network changes and trigger sync
          networkService.onNetworkChange.listen((isOnline) {
            if (isOnline) {
              final sellBloc = BlocProvider.of<SellBloc>(context);
              // When the internet is available, sync unsynced sells
              final syncService = SyncService(
                  sellRepository.database,
                  sellBloc
              );
              syncService.syncUnsyncedSells();
              // Show Snackbar indicating the sync is happening
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(content: Text('Items are syncing with the server...')),
              );
            } else {
              // Show Snackbar indicating no internet
              scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(content: Text('No internet connection, syncing will resume once online.')),
              );
            }
          });

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'POS System',
            theme: ThemeData(primarySwatch: Colors.blue),
            scaffoldMessengerKey: scaffoldMessengerKey, // Attach the key here for showing Snackbars
            home: SellScreen(database: sellRepository.database, ),
          );
        },
      ),
    );
  }
}
