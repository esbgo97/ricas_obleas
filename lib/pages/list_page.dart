import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ricas_obleas/db/operation.dart';
import 'package:ricas_obleas/pages/save_page.dart';

import '../models/order.dart';
import '../models/product.dart';

class ListPage extends StatelessWidget {
  static const String ROUTE = "/";

  @override
  Widget build(BuildContext context) {
    return _SaleList();
  }
}

class _SaleList extends StatefulWidget {
  @override
  SaleListState createState() => SaleListState();
}

class SaleListState extends State<_SaleList> {
  List<Order> orders = [];

  @override
  void initState() {
    _loadSales();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Listado de Ventas")),
      body: Container(
        child: ListView.builder(
            itemCount: orders.length, itemBuilder: (_, i) => _createItem(i)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, SavePage.ROUTE, arguments: Product())
              .then((value) => setState(() {
                    _loadSales();
                  }));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  _loadSales() async {
    var dbOrders = await Operation.getOrders();
    setState(() {
      orders = dbOrders;
    });
  }

  _createItem(int i) {
    var order = orders[i];

    return Dismissible(
        key: Key(i.toString()),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          print("deleting ${order.id}");
          Operation.deleteOrder(order);
        },
        background: Container(
          color: Colors.redAccent,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        child: ListTile(
          leading: Text(order.id.toString()),
          title: Text(" \$${order.totalPrice}"),
          subtitle: Text("(${order.date})"),
          trailing: IconButton(
            icon: Icon(
              Icons.edit,
            ),
            onPressed: () {
              print("Editar ${order.id}");
              Navigator.pushNamed(context, SavePage.ROUTE, arguments: order)
                  .then((value) => setState(() {
                        _loadSales();
                      }));
            },
          ),
          titleAlignment: ListTileTitleAlignment.center,
        ));
    ;
  }
}
