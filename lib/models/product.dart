class Product {
  int? id;
  int count;
  String ingredients;
  double price;
  double total;
  int idOrder;
  Product({this.id, this.count = 0,this.ingredients= "",this.price= 0, this.total = 0, this.idOrder=0});

  Map<String,dynamic> toMap(){
    return {
      "id":this.id,
      "count":this.count,
      "price":this.price,
      "ingredients":this.ingredients,
      "total":this.total,
      "idOrder":this.idOrder
    };
  }
}