class DepthEntity {
  double price;
  double vol;

  DepthEntity(this.price, this.vol);

  @override
  String toString() {
    return 'Data{price: $price, vol: $vol}';
  }
}
