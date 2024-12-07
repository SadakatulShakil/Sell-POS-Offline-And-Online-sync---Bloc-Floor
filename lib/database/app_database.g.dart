// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  SellDao? _sellDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Sell` (`id` INTEGER NOT NULL, `productName` TEXT NOT NULL, `price` REAL NOT NULL, `quantity` INTEGER NOT NULL, `isSynced` INTEGER NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  SellDao get sellDao {
    return _sellDaoInstance ??= _$SellDao(database, changeListener);
  }
}

class _$SellDao extends SellDao {
  _$SellDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _sellInsertionAdapter = InsertionAdapter(
            database,
            'Sell',
            (Sell item) => <String, Object?>{
                  'id': item.id,
                  'productName': item.productName,
                  'price': item.price,
                  'quantity': item.quantity,
                  'isSynced': item.isSynced ? 1 : 0
                }),
        _sellUpdateAdapter = UpdateAdapter(
            database,
            'Sell',
            ['id'],
            (Sell item) => <String, Object?>{
                  'id': item.id,
                  'productName': item.productName,
                  'price': item.price,
                  'quantity': item.quantity,
                  'isSynced': item.isSynced ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Sell> _sellInsertionAdapter;

  final UpdateAdapter<Sell> _sellUpdateAdapter;

  @override
  Future<List<Sell>> getAllSells() async {
    return _queryAdapter.queryList('SELECT * FROM Sell',
        mapper: (Map<String, Object?> row) => Sell(
            id: row['id'] as int,
            productName: row['productName'] as String,
            price: row['price'] as double,
            quantity: row['quantity'] as int,
            isSynced: (row['isSynced'] as int) != 0));
  }

  @override
  Future<List<Sell>> getUnsyncedSells() async {
    return _queryAdapter.queryList('SELECT * FROM Sell WHERE isSynced = 0',
        mapper: (Map<String, Object?> row) => Sell(
            id: row['id'] as int,
            productName: row['productName'] as String,
            price: row['price'] as double,
            quantity: row['quantity'] as int,
            isSynced: (row['isSynced'] as int) != 0));
  }

  @override
  Future<void> insertSell(Sell sell) async {
    await _sellInsertionAdapter.insert(sell, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateSell(Sell sell) async {
    await _sellUpdateAdapter.update(sell, OnConflictStrategy.abort);
  }
}
