class DepthEntity {
  double price;
  double amount;

  DepthEntity(this.price, this.amount);

  @override
  String toString() {
    return 'Data{price: $price, amount: $amount}';
  }
}