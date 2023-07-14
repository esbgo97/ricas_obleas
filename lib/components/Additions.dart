import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef MyCallback = void Function(bool val, String name);

class Ingredients extends StatelessWidget {
  final MyCallback callback;
  final List<String> checks;
  Ingredients({ required this.callback, required this.checks});

  @override
  Widget build(BuildContext context) {
    var ingredients = ["Queso", "Maní", "Coco"];
    return Column(
      children: [
        Text(
          "Ingredientes (\$ 1.000)",
          style: TextStyle(fontSize: 20),
        ),
        ...ingredients.map((e) => CheckboxItem(e, checks, callback)).toList()
      ],
    );
  }
}

class Sweets extends StatelessWidget {
  final MyCallback callback;
  final List<String> checks;
  Sweets({required this.callback, required this.checks});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var sweets = ["Mora", "Chocolate", "Maracuyá", "Chips"];
    return Column(children: [
      Text(
        "Dulces (\$ 500)",
        style: TextStyle(fontSize: 20),
      ),
      ...sweets.map((e) => CheckboxItem(e,checks,callback)).toList()
    ]);
  }
}

class CheckboxItem extends StatefulWidget {
  var label = "";
  var isChecked = false;
  MyCallback callback2 = (val,str)=>{};

  CheckboxItem(String name, List<String> checks, MyCallback callback) {
    label = name;
    callback2 = callback;
    isChecked = checks.contains(name);
    print(checks.join(","));
  }

  @override
  State<CheckboxItem> createState() => _CheckboxItemState();
}

class _CheckboxItemState extends State<CheckboxItem> {
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: widget.isChecked,
          onChanged: (val) {
            setState(() {
              isChecked = val ?? false;
            });
            widget.callback2(val ?? false, widget.label);
          },
        ),
        Container(
          width: 100,
          child: Text(
            widget.label,
          ),
        )
      ],
    );
    /*
    return CheckboxListTile(
      dense: true,
      value: false,
      onChanged: (val) {},
      title: Text(label),
    );
    */
  }
}
