import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:ricas_obleas/components/Additions.dart';
import 'package:ricas_obleas/db/operation.dart';
import 'package:ricas_obleas/models/order.dart';

import '../models/product.dart';

class SavePageArguments{
  List<Product> products;
  Order order;
  SavePageArguments({required this.order, required this.products});
}

class SavePage extends StatefulWidget {
  static const String ROUTE = "/save";

  @override
  State<SavePage> createState() => _SavePageState();
}

class _SavePageState extends State<SavePage> {
  var count = 1;
  double price = 2000;
  List<String> additions = [];
  List<Product> productList = [];

  void onChangeSweet(bool val, String name) {
    if (val) {
      setState(() {
        price += 500;
        additions.add(name);
      });
    } else {
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
    Order order = ModalRoute.of(context)!.settings.arguments as Order;
    var title = "Nueva Venta";
    if (order.id != null && order.id! > 0) {
      title = "Venta No. ${order.id}";
      //_loadProducts(order.id ?? 0);
    }
    return WillPopScope(
      onWillPop: _onWillPopScope,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Container(
          child: _buildForm(order),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.payments),
          onPressed: () async {
            var responseMessage = "";
            if (productList.length > 0) {
              //SAVE ORDER
              var totalPrice = productList.fold<double>(
                  0, (value, element) => value + element.total);
              var totalCount = productList.fold(
                  0, (previousValue, element) => previousValue + element.count);

              var idOrder = await Operation.saveOrder(Order(
                  count: totalCount,
                  price: totalPrice,
                  date: DateTime.now().toIso8601String()));

              print("save Order $idOrder ");

              //SAVE PRODUCTS
              for (var product in productList) {
                var idProduct = await Operation.saveProduct(Product(
                    count: product.count,
                    ingredients: product.ingredients,
                    price: product.price,
                    total: product.total,
                    idOrder: idOrder));
                print("saved product $idProduct from order $idOrder");
              }
              print("---finishOrder---");
              responseMessage = "Se guardó la venta correctamente";
            } else {
              responseMessage = "Debe agregar al menos un producto";
            }
            final snackbar = SnackBar(content: Text(responseMessage));
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          },
        ),
      ),
    );
  }

  void onAddProduct(Product sale) {
    setState(() {
      productList.add(sale);
      sale = Product();
    });
  }

  void onRemoveSaleItem(Product sale) {
    setState(() {
      productList.remove(sale);
    });
  }

  Widget _buildForm(Order sale) {
    final cop = new NumberFormat("#,##0.00", "es_CO");
    var description = "[Sencilla]";
    if (additions.length > 0) {
      description = additions.join(", ");
    }
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
                    " ${0} / ${productList.fold<int>(0, (value, element) => value + element.count)}",
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
                    description,
                    overflow: TextOverflow.fade,
                  ),
                ],
              ),
              FilledButton(
                child: Text("Agregar"),
                onPressed: () async {
                  onAddProduct(Product(
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
          _buildOrder(productList),
          Container(
            height: 50,
            child: Text(
              "Total: \$ ${cop.format(productList.fold<double>(0, (value, element) => value + element.total))}",
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
                    /*
                    TODO: implement on ready product
                    trailing: Checkbox(
                      value: false,
                      onChanged: (val) {},
                    ),
                     */
                  ));
            }));
  }

  _loadProducts(int idOrder) async {
   var products = await Operation.getProducts(idOrder);
   print("products: "+ products.toString());
   setState(() {
     productList = products;
   });
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
