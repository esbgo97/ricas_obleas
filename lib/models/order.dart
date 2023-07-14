class Order {
  int? id;
  int count;
  double price;
  String date;

  Order({
    this.id,
    this.count = 0,
    this.price = 0,
    this.date = "",
  });

  Map<String, dynamic> toMap() {
    return {
      "id": this.id,
      "count": this.count,
      "price": this.price,
      "date": this.date,
    };
  }
}
