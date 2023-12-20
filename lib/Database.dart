import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  late Database _database;

  Future<void> initialize() async {
    final String path = join(await getDatabasesPath(), 'driver_database.db');
    print('joined');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE driver(
            id INTEGER PRIMARY KEY,
            email TEXT,
            phoneNumber TEXT,
            username TEXT,
            car_model TEXT,
            car_plateNumber TEXT,
            car_plateLetters TEXT

          )
        ''');
      },
    );
    print('opened');
  }

  Future<void> printDatabaseContent() async {
    if (_database == null) {
      print('Database is not yet initialized');
      return;
    }

    final List<Map<String, dynamic>> queryResult = await _database.query('driver');
    if (queryResult.isNotEmpty) {
      print('anaaa mawgood ahoooo');
      queryResult.forEach((row) {
        print('User data: $row');
      });
    } else {
      print('No USER DATA AVLIABLE');
    }
  }

  // Incorporating MyDatabase functionality into DatabaseService
  Future<Database?> checkData() async {
    if (_database == null) {
      print('initializing');
      await initialize(); // Ensure database is initialized
      return _database;
    } else {
      print('initialized already');
      return _database;
    }
  }

  Future<void> resetDatabase() async {
    final String path = join(await getDatabasesPath(), 'driver_database.db');
    await deleteDatabase(path);
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE driver(
            id INTEGER PRIMARY KEY,
            email TEXT,
            phoneNumber TEXT,
            username TEXT,
            car_model TEXT,
            car_plateNumber TEXT,
            car_plateLetters TEXT
          )
        ''');
      },
    );
  }

  Future<void> syncFirestoreDataToSQLite(Map<String, dynamic> driverData) async {
    if (_database == null) {
      print('Database is not yet initialized');
      return;
    }

    print('syncing');
    if (driverData.containsKey('password')) {
      driverData.remove('password');
    }
    if (driverData.containsKey('car-color')) {
      driverData.remove('car-color');
    }

    List<Map<String, dynamic>> existingData = await _database.query('driver');
    if (existingData.isNotEmpty) {
      print('data not empty');
      // If there's existing data, update it
      await _database.update('driver', driverData);
    } else {
      // If no existing data, insert the new data
      print('mafesh data');
      await _database.insert('driver', driverData);
    }

    print('synced');
  }


  Future<Map<String, dynamic>> fetchDriverDataFromSQLite() async {
    if (_database == null) {
      print('Database is not yet initialized');
      return {};
    }
    print('fetchUserDataFromSQLite');
    final List<Map<String, dynamic>> queryResult = await _database.query('driver');
    if (queryResult.isNotEmpty) {
      print('fetched');
      print(queryResult.first);
      return queryResult.first;
    }
    return {};
  }
}