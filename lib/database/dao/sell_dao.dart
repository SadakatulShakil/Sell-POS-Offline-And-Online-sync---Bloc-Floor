import 'package:floor/floor.dart';

import '../../models/sell.dart';

@dao
abstract class SellDao {
  @Query('SELECT * FROM Sell')
  Future<List<Sell>> getAllSells();

  @Query('SELECT * FROM Sell WHERE isSynced = 0')
  Future<List<Sell>> getUnsyncedSells();

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertSell(Sell sell);

  @update
  Future<void> updateSell(Sell sell);
}
