extension NumExt on num? {
  bool get nullOrZero {
    if (this == null || this == 0) {
      return true;
    }
    return this!.abs().toStringAsFixed(4) == "0.0000";
  }
}
