import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ricas_obleas/components/Additions.dart';
import 'package:ricas_obleas/db/operation.dart';

import '../models/sale.dart';

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
  List<Sale> saleItems = [];

  void onChangeSweet(bool val, String name) {
    var ins = description.split(",");
    if (val) {
      ins.add(name);

      setState(() {
        price += 500;
        additions.add(name);
        description = ins.join(",");
      });
    } else {
      ins.remove(name);

      setState(() {
        price -= 500;
        additions.remove(name);
        description = ins.join(",");
      });
    }
  }

  void onChangeIngredient(bool val, String name) {
    if (val) {
      var ins = description.split(",");
      ins.add(name);

      setState(() {
        price += 1000;
        additions.add(name);
        description = ins.join(",");
      });
    } else {
      var ins = description.split(",");
      ins.remove(name);

      setState(() {
        price -= 1000;
        additions.add(name);
        description = ins.join(",");
      });
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Sale sale = ModalRoute.of(context)!.settings.arguments as Sale;

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
          },
        ),
      ),
    );
  }

  void onAddSaleItem(Sale sale) {
    setState(() {
      saleItems.add(sale);
      sale = Sale();
    });
  }

  Widget _buildForm(Sale sale) {
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
                    "${saleItems.fold<int>(0, (value, element) => value + element.count)}",
                    style: TextStyle(fontSize: 36),
                  ),
                  Text("Obleas para preparar")
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
                  Text("(\$$price c/u) [$description]"),
                ],
              ),
              FilledButton(
                child: Text("Agregar"),
                onPressed: () async {
                  onAddSaleItem(Sale(
                    count: count,
                    ingredients: description,
                    price: price,
                    totalPrice: (count * price),
                    date: DateTime.now().toIso8601String(),
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
              "Total: \$ ${cop.format(saleItems.fold<double>(0, (value, element) => value + element.totalPrice))}",
              style: TextStyle(fontSize: 32, color: Colors.blue),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildOrder(List<Sale> sales) {
    return Expanded(
        child: ListView.builder(
            itemCount: sales.length,
            itemBuilder: (BuildContext context, int i) {
              final item = sales[i];
              print(item.toString());
              return Dismissible(
                  key: Key(i.toString()),
                  child: ListTile(
                    leading: Text("${i + 1}"),
                    titleAlignment: ListTileTitleAlignment.center,
                    title: Text("${item.count}: ${item.totalPrice}"),
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
