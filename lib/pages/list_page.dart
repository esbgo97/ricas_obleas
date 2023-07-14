import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ricas_obleas/db/operation.dart';
import 'package:ricas_obleas/pages/save_page.dart';

import '../models/sale.dart';

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
  List<Sale> sales = [];

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
            itemCount: sales.length, itemBuilder: (_, i) => _createItem(i)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, SavePage.ROUTE, arguments: Sale())
              .then((value) => setState(() {
                    _loadSales();
                  }));
        },
        child: Icon(Icons.add),
      ),
    );
  }

  _loadSales() async {
    var dbSales = await Operation.getSales();
    setState(() {
      sales = dbSales;
    });
  }

  _createItem(int i) {
    var sale = sales[i];

    return Dismissible(
        key: Key(i.toString()),
        direction: DismissDirection.startToEnd,
        onDismissed: (direction) {
          print("deleting ${sale.id}");
          Operation.delete(sale);
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
          leading: Text(sale.id.toString()),
          title: Text("${sale.count}, \$${sale.totalPrice}"),
          subtitle: Text("${sale.ingredients}, (${sale.date})"),
          trailing: IconButton(
            icon: Icon(
              Icons.edit,
            ),
            onPressed: () {
              print("Editar ${sale.id}");
              Navigator.pushNamed(context, SavePage.ROUTE, arguments: sale)
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
