import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/order.dart';
import '../models/product.dart';

List<String> SqlQueries = [
  "CREATE TABLE orders (id INTEGER PRIMARY KEY, price REAL, date TEXT)",
  "CREATE TABLE products (id INTEGER PRIMARY KEY AUTOINCREMENT, count INT, ingredients TEXT, price REAL, totalPrice REAL);",
  "CREATE TABLE order_sale (id INTEGER PRIMARY KEY, idorder INTEGER REFERENCES orders(id), idsale INTEGER REFERENCES products(id));"
];

class Operation {
  static Future<Database> openDB() async {
    return openDatabase(join(await getDatabasesPath(), "obleas_db"),
        onCreate: (db, version) {
      for (var query in SqlQueries) {
        db.execute(query);
      }
      return true;
    }, version: 2);
  }

  static Future<void> saveOrder(Order order) async {
    Database db = await openDB();
    var result = db.insert("orders", order.toMap());
    print(result);
    return;
  }

  static Future<void> saveProduct(Product sale) async {
    Database db = await openDB();
    var result = db.insert("products", sale.toMap());
    print(result);
    return;
  }

  static Future<List<Product>> getProducts() async {
    Database db = await openDB();
    var result = await db.query("products", orderBy: "id DESC");
    var mappedItems = List.generate(
        result.length,
        (index) => Product(
            id: int.parse(result[index]["id"].toString()),
            count: int.parse(result[index]["count"].toString()),
            ingredients: result[index]["ingredients"].toString(),
            price: double.parse(result[index]["price"].toString()),
            total: double.parse(result[index]["totalPrice"].toString())));
    return mappedItems;
  }

  static Future<List<Order>> getOrders() async {
    Database db = await openDB();
    var result = await db.query("orders", orderBy: "id DESC");
    var mapped = List.generate(
        result.length,
        (index) => Order(
            id: int.parse(result[index]["id"].toString()),
            totalPrice: double.parse(result[index]["price"].toString()),
            date: result[index]["date"].toString()));
    return mapped;
  }

  static Future<void> deleteProduct(Product sale) async {
    var db = await openDB();
    var result = db.delete("products", where: "id = ?", whereArgs: [sale.id]);
    print(result.toString());
    return;
  }

  static Future<void> deleteOrder(Order order) async {
    var db = await openDB();
    var result = db.delete("orders", where: "id = ?", whereArgs: [order.id]);
    print(result.toString());
    return;
  }

  static Future<void> updateProduct(Product sale) async {
    Database db = await openDB();
    var result =
        db.update("sales", sale.toMap(), where: "id = ?", whereArgs: [sale.id]);
    print(result.toString());
    return;
  }
}
