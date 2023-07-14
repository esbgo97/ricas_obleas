import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  final cop = new NumberFormat("#,##0.00", "es_CO");
  @override
  void initState() {
    _loadOrders();
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
          Navigator.pushNamed(context, SavePage.ROUTE, arguments: Order())
              .then((value) => setState(() {
                    _loadOrders();
                  }));
        },
        child: Icon(Icons.add),
      ),
      bottomSheet: Row(children: [
        FilledButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateColor.resolveWith(
                    (states) => Colors.redAccent)),
            onPressed: () async {
              var result = await Operation.deleteDatabase();
              var message = "";
              if (result) {
                message = "Se eliminó correctamente";
              } else {
                message = "Ocurrió un problema";
              }
              final snackbar = SnackBar(content: Text(message));
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [Text("Limpiar Base de Datos"), Icon(Icons.delete)],
            ))
      ]),
    );
  }

  _loadOrders() async {
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
          title:Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
            Text("${order.count}",style: TextStyle(fontStyle: FontStyle.italic)),
            Text("\$${cop.format(order.price)}"),
          ],),

          subtitle: Text("(${order.date})"),
          trailing: IconButton(
            icon: Icon(
              Icons.edit,
            ),
            onPressed: () {
              print("Editar ${order.id}");
              Navigator.pushNamed(context, SavePage.ROUTE, arguments: order)
                  .then((value) => setState(() {
                        _loadOrders();
                      }));
            },
          ),
          titleAlignment: ListTileTitleAlignment.center,
        ));
    ;
  }
}
