import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ricas_obleas/components/Additions.dart';
import 'package:ricas_obleas/db/operation.dart';

import '../models/product.dart';

class SavePage extends StatefulWidget {
  static const String ROUTE = "/save";

  @override
  State<SavePage> createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  var count = 1;
  double price = 2000;
  var description = "";
  List<String> additions = [];
  List<Product> saleItems = [];

  void onChangeSweet(bool val, String name) {
    var ins = description.split(",");
    if (val) {
      ins.add(name);

      setState(() {
        price += 500;
        additions.add(name);
      });
    } else {
      ins.remove(name);

      setState(() {
        price -= 500;
        additions.remove(name);
      });
    }
  }

  void onChangeIngredient(bool val, String name) {
    if (val) {
      setState(() {
        price += 1000;
        additions.add(name);
      });
    } else {
      setState(() {
        price -= 1000;
        additions.remove(name);
      });
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Product sale = ModalRoute.of(context)!.settings.arguments as Product;

    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Nueva Venta"),
        ),
        body: Container(
          child: _buildForm(sale),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.payments),
          onPressed: () async {

/*
            var validate = _formKey.currentState?.validate();
            if (validate == true) {
              if (sale.id != null && sale.id! > 0) {
                //Update Sale
                sale.count = count;
                sale.ingredients = description;
                sale.price = price;
                sale.totalPrice = (count * price);

                var result = await Operation.update(sale);
              } else {
                //Save new Sale
                var result = await Operation.insert(Sale(
                  count: count,
                  ingredients: description,
                  price: price,
                  totalPrice: (count * price),
                  date: DateTime.now().toIso8601String(),
                ));
              }

              final snackbar =
                  SnackBar(content: Text("Se Registro la venta correctamente"));
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            }
* */

            if (saleItems.length > 0) {

            } else {
              final snackbar =
              SnackBar(content: Text("Debe agregar al menos un producto"));
              ScaffoldMessenger.of(context).showSnackBar(snackbar);
            }
          },
        ),
      ),
    );
  }

  void onAddSaleItem(Product sale) {
    setState(() {
      saleItems.add(sale);
      sale = Product();
    });
  }

  void onRemoveSaleItem(Product sale) {
    setState(() {
      saleItems.remove(sale);
    });
  }

  Widget _buildForm(Product sale) {
    final cop = new NumberFormat("#,##0.00", "es_CO");
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Text("A continuación ingrese el pedido de la nueva venta"),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              NumberPicker(
                  itemWidth: 50,
                  itemHeight: 30,
                  minValue: 1,
                  maxValue: 100,
                  value: count,
                  onChanged: (val) {
                    setState(() {
                      count = val;
                    });
                    print("cantidad Seleccionada $val");
                  }),
              Column(
                children: [
                  Text(
                    " ${0} / ${saleItems.fold<int>(0, (value, element) => value + element.count)}",
                    style: TextStyle(fontSize: 36),
                  ),
                  Text("Obleas Preparadas")
                ],
              )
            ],
          ),
          Divider(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Ingredients(
                callback: onChangeIngredient,
                checks: additions,
              ),
              Sweets(
                callback: onChangeSweet,
                checks: additions,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Text(
                    "Valor : \$ ${cop.format(price * count)} ",
                    style: TextStyle(fontSize: 28),
                  ),
                  Text("(\$$price c/u)"),
                  Text(
                    "[${additions.join(", ")}]",
                    overflow: TextOverflow.fade,
                  ),
                ],
              ),
              FilledButton(
                child: Text("Agregar"),
                onPressed: () async {
                  onAddSaleItem(Product(
                    count: count,
                    ingredients: description,
                    price: price,
                    total: (count * price),
                  ));
                  setState(() {
                    count = 1;
                    description = "";
                    price = 2000;
                    additions = [];
                  });
                },
              ),
            ],
          ),
          Divider(),
          _buildOrder(saleItems),
          Container(
            height: 50,
            child: Text(
              "Total: \$ ${cop.format(saleItems.fold<double>(0, (value, element) => value + element.total))}",
              style: TextStyle(fontSize: 32, color: Colors.blue),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOrder(List<Product> sales) {
    return Expanded(
        child: ListView.builder(
            itemCount: sales.length,
            itemBuilder: (BuildContext context, int i) {
              final item = sales[i];
              print(item.toString());

              return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) {
                    onRemoveSaleItem(sales[i]);
                  },
                  background: Container(
                    alignment: Alignment.centerLeft,
                    color: Colors.redAccent,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: ListTile(
                    leading: Text("${i + 1}"),
                    titleAlignment: ListTileTitleAlignment.center,
                    title: Text("${item.count}: ${item.total}"),
                    subtitle: Text(item.ingredients),
                    trailing: Checkbox(
                      value: false,
                      onChanged: (val) {},
                    ),
                  ));
            }));
  }

  Future<bool> _onWillPopScope() {
    return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("¿Desea cancelar la venta?"),
            content: Text("No se guardará la información."),
            actions: [
              FilledButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.orangeAccent)),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text("Si")),
              FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text("No")),
            ],
          );
        }).then((value) => value ?? false);
  }
}
