import 'package:ricas_obleas/db/product_dao.dart';

import '../db/order_dao.dart';
import '../models/order.dart';
import '../models/product.dart';

class SaleRepository {
  OrderDAO orderDAO;
  ProductDAO productDAO;

  SaleRepository({required this.orderDAO, required this.productDAO});

  Future<int> SaveSale(Order order, List<Product> products) async {
    var idOrder = await orderDAO.saveOrder(order);
    List<int> idProducts = await SaveProducts(idOrder, products);
    return idOrder;
  }

  Future<List<int>> SaveProducts(int idOrder, List<Product> products) async {
    List<int> idProducts = [];
    for (var product in products) {
      product.idOrder = idOrder;
      var productId = await productDAO.saveProduct(product);
      idProducts.add(productId);
    }
    return idProducts;
  }

  Future<List<Order>> GetSales() async {
    var result = await orderDAO.getOrders();
    return result;
  }

  Future<List<Product>> GetProductsByOrder(int idOrder) async {
    var result = await productDAO.getProducts(idOrder);
    return result;
  }

  Future<bool> UpdateSale(Order order, List<Product> products) async {
    var deletedOrder = await orderDAO.updateOrder(order);

    //Recreating Products
    var delProds = await productDAO.deleteProductsByOrderId(order.id ?? 0);
    var productsIds = await SaveProducts(order.id ?? 0, products);

    return true;
  }

  Future<bool> DeleteSale(Order order) async {
    var delProducts = await productDAO.deleteProductsByOrderId(order.id ?? 0);
    var delOrder = await orderDAO.deleteOrder(order);
    return delOrder > 0;
  }

  Future<bool> DeleteProduct(Product product) async {
    var result = await productDAO.deleteProduct(product);
    return result > 0;
  }
}
