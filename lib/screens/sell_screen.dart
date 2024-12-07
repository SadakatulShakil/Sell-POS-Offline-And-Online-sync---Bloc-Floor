import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/network/network_bloc.dart';
import '../blocs/network/network_state.dart';
import '../blocs/sell/sell_bloc.dart';
import '../database/app_database.dart';
import '../main.dart';
import '../models/sell.dart';
import '../services/sync_service.dart';

class SellScreen extends StatefulWidget {
  final AppDatabase database;

  SellScreen({required this.database});

  @override
  _SellScreenState createState() => _SellScreenState();
}

class _SellScreenState extends State<SellScreen> {
  late final SyncService _syncService;
  final TextEditingController productController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final sellBloc = BlocProvider.of<SellBloc>(context);
    _syncService = SyncService(widget.database, sellBloc);
    _syncService.listenToNetworkChanges(context);
  }

  @override
  void dispose() {
    productController.dispose();
    priceController.dispose();
    super.dispose();
  }

  Future<void> _addSell() async {
    if (productController.text.isNotEmpty && priceController.text.isNotEmpty) {
      final newSell = Sell(
        id: DateTime.now().millisecondsSinceEpoch,
        productName: productController.text,
        price: double.parse(priceController.text),
        quantity: 1,
        isSynced: false,
      );

      await widget.database.sellDao.insertSell(newSell);

      // Trigger sync if connected
      final networkState = BlocProvider.of<NetworkBloc>(context).state;
      print("test state: "+ networkState.toString());
      if (networkState is NetworkConnected) {
        await _syncService.syncUnsyncedSells();
      } else {
        scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Product added, waiting for network to sync!')),
        );
      }

      productController.clear();
      priceController.clear();
      setState(() {});
    } else {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text('Please enter valid product details.')),
      );
    }
  }

  Future<List<Sell>> _fetchSells() {
    return widget.database.sellDao.getAllSells();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('POS System')),
      body: FutureBuilder<List<Sell>>(
        future: _fetchSells(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading sells.'));
          }

          final sells = snapshot.data ?? [];

          return ListView.builder(
            itemCount: sells.length,
            itemBuilder: (context, index) {
              final sell = sells[index];
              return ListTile(
                title: Text(sell.productName),
                subtitle: Text('Price: ${sell.price}, Qty: ${sell.quantity}'),
                trailing: sell.isSynced
                    ? Icon(Icons.check, color: Colors.green)
                    : GestureDetector(
                      onTap: ()async{
                        await _syncService.syncUnsyncedSells();
                        setState(() {

                        });
                      },
                    child: Icon(Icons.sync, color: Colors.red)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSellDialog(),
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddSellDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: productController,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await _addSell();
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}