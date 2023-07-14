import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/sale.dart';

class Operation {
  static Future<Database> openDB() async {
    return openDatabase(join(await getDatabasesPath(), "obleas_db"),
        onCreate: (db, version) {
      return db.execute(
          "CREATE TABLE sales (id INTEGER PRIMARY KEY AUTOINCREMENT, count INT, ingredients TEXT, price REAL, totalPrice REAL, date TEXT);");
    }, version: 1);
  }

  static Future<void> insert(Sale sale) async {
    Database db = await openDB();
    var result = db.insert("sales", sale.toMap());
    print(result.toString());
    return;
  }

  static Future<List<Sale>> getSales() async {
    Database db = await openDB();
    var result = await db.query("sales",orderBy: "id DESC");
    var mappedItems = List.generate(
        result.length,
        (index) => Sale(
            id: int.parse(result[index]["id"].toString()),
            count: int.parse(result[index]["count"].toString()),
            ingredients: result[index]["ingredients"].toString(),
            price: double.parse(result[index]["price"].toString()),
            totalPrice: double.parse(result[index]["totalPrice"].toString()),
            date: result[index]["date"].toString()));
    return mappedItems;
  }

  static Future<void> delete(Sale sale) async {
    var db = await openDB();
    var result = db.delete("sales", where: "id = ?", whereArgs: [sale.id]);
    print(result.toString());
    return;
  }

  static Future<void> update(Sale sale) async {
    Database db = await openDB();
    var result =
        db.update("sales", sale.toMap(), where: "id = ?", whereArgs: [sale.id]);
    print(result.toString());
    return;
  }
}
