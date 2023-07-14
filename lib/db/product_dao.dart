import 'package:sqflite/sqflite.dart';

import '../models/product.dart';

class ProductDAO {
  Database db;
  String tableName = "products";
  ProductDAO({required this.db});

  Future<int> saveProduct(Product sale) async {
    var result = db.insert(tableName, sale.toMap());
    print("saved product $result");
    return result;
  }

  Future<List<Product>> getProducts(int? idOrder) async {
    var whereArg = "idOrder";
    if (idOrder! > 0) {
      whereArg = idOrder.toString();
    }
    var result = await db.query(tableName,
        where: "idOrder = ?", whereArgs: [whereArg], orderBy: "id DESC");
    var mappedItems = List.generate(
        result.length,
        (index) => Product(
            id: int.parse(result[index]["id"].toString()),
            count: int.parse(result[index]["count"].toString()),
            ingredients: result[index]["ingredients"].toString(),
            price: double.parse(result[index]["price"].toString()),
            total: double.parse(result[index]["total"].toString())));
    print("found ${result.length} $tableName");
    return mappedItems;
  }

  Future<void> updateProduct(Product product) async {
    var result = db.update(tableName, product.toMap(),
        where: "id = ?", whereArgs: [product.id]);
    print("updated product $result");
    return;
  }

  Future<int> deleteProduct(Product product) async {
    var result = db.delete(tableName, where: "id = ?", whereArgs: [product.id]);
    print("deleted product ${product.id}");
    return result;
  }

  Future<int> deleteProductsByOrderId(int orderId) async {
    var result = db.delete(tableName, where: "idOrder = ?", whereArgs: [orderId]);
    print("deleted $result products of order ${orderId}");
    return result;
  }

}
