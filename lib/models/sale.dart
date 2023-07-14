class Sale {
  int? id;
  int count;
  String ingredients;
  double price;
  double totalPrice;
  String date;

  Sale({this.id, this.count = 0,this.ingredients= "",this.price= 0, this.totalPrice = 0,this.date = ""});

  Map<String,dynamic> toMap(){
    return {
      "id":this.id,
      "count":this.count,
      "price":this.price,
      "ingredients":this.ingredients,
      "price": this.price,
      "totalPrice":this.totalPrice,
      "date": this.date
    };
  }
}