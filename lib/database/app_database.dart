import 'package:floor/floor.dart';
import '../models/sell.dart';
import 'dao/sell_dao.dart';
import 'dart:async';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'app_database.g.dart'; // Generated code.

@Database(version: 1, entities: [Sell])
abstract class AppDatabase extends FloorDatabase {
  SellDao get sellDao;
}
