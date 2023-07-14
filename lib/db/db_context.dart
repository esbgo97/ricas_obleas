import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

List<String> SqlQueries = [
  "CREATE TABLE orders (id INTEGER PRIMARY KEY AUTOINCREMENT, count INT, price REAL, date TEXT);",
  "CREATE TABLE products (id INTEGER PRIMARY KEY AUTOINCREMENT, count INT, ingredients TEXT, price REAL, total REAL, idOrder INTEGER REFERENCES orders(id));",
];

class DbContext {
  static Future<Database> openDB() async {
    return openDatabase(join(await getDatabasesPath(), "obleas_db"),
        onCreate: (db, version) {
      for (var query in SqlQueries) {
        db.execute(query);
      }
      return true;
    }, version: 3);
  }

  static Future<bool> deleteDatabase() async {
    try {
      Database db = await openDB();
      await databaseFactory.deleteDatabase(db.path);
      return true;
    } catch (err) {
      print(err.toString());
      return false;
    }
  }

}
