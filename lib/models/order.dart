import 'dart:ffi';

import 'package:ricas_obleas/models/product.dart';

class Order {
  int? id;
  double totalPrice;
  String date;
  Order({this.id, this.totalPrice = 0, this.date = "", });
  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "totalPrice": this.totalPrice,
      "date": this.date,
    };
  }
}
