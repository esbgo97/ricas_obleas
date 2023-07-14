import 'package:sqflite/sqflite.dart';

import '../models/order.dart';

class OrderDAO {
  String tableName = "orders";
  Database db;
  OrderDAO({required this.db});

  Future<int> saveOrder(Order order) async {
    var result = db.insert(tableName, order.toMap());
    print("saved order $result");
    return result;
  }

  Future<List<Order>> getOrders() async {
    var result = await db.query(tableName, orderBy: "id DESC");

    var mapped = List.generate(
        result.length,
            (index) => Order(
            id: int.parse(result[index]["id"].toString()),
            count: int.parse(result[index]["count"].toString()),
            price: double.parse(result[index]["price"].toString()),
            date: result[index]["date"].toString()));
    print("found ${result.length} $tableName}");
    return mapped;
  }

  Future<bool> updateOrder(Order order) async {
    var result = await db.update(tableName, order.toMap(),where: "id = ?",whereArgs: [order.id]);
    return result > 0;
  }

  Future<int> deleteOrder(Order order) async {
    var result = await db.delete(tableName, where: "id = ?", whereArgs: [order.id]);
    print("deleted order ${order.id}");
    return result;
  }

}