import '../entity/k_entity.dart';

class KLineEntity extends KEntity {
  late double open;
  late double high;
  late double low;
  late double close;
  late double vol;
  late double amount;
  double? change;
  double? ratio;
  int? time;

  KLineEntity.fromCustom({
    required this.amount,
    required this.open,
    required this.close,
    this.change,
    this.ratio,
    required this.time,
    required this.high,
    required this.low,
    required this.vol,
  });

  KLineEntity.fromJson(Map<String, dynamic> json) {
    open = json['open']!.toDouble();
    high = json['high']!.toDouble();
    low = json['low']!.toDouble();
    close = json['close']!.toDouble();
    vol = json['vol']!.toDouble();
    amount = json['amount']!.toDouble();
    time = json['time']?.toInt();
    //兼容火币数据
    if (time == null) {
      time = (json['id']?.toInt());
      if (time != null) {
        time = time! * 1000;
      }
    }
    ratio = json['ratio']?.toDouble();
    change = json['change']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = this.time;
    data['open'] = this.open;
    data['close'] = this.close;
    data['high'] = this.high;
    data['low'] = this.low;
    data['vol'] = this.vol;
    data['amount'] = this.amount;
    data['ratio'] = this.ratio;
    data['change'] = this.change;
    return data;
  }

  @override
  String toString() {
    return 'MarketModel{open: $open, high: $high, low: $low, close: $close, vol: $vol, time: $time, amount: $amount, ratio: $ratio, change: $change}';
  }
}
