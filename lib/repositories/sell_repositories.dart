import '../database/app_database.dart';
import '../models/sell.dart';

class SellRepository {
  final AppDatabase database;

  SellRepository(this.database);

  Future<List<Sell>> getAllSells() => database.sellDao.getAllSells();

  Future<void> addSell(Sell sell) => database.sellDao.insertSell(sell);
}
