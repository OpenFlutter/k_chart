import '../entity/k_entity.dart';

class KLineEntity extends KEntity {
  double? open;
  double? high;
  double? low;
  double? close;
  double? vol;
  double? amount;
  double? change;
  double? ratio;
  int? time;

  KLineEntity.fromCustom({
    this.amount,
    this.open,
    this.close,
    this.change,
    this.ratio,
    this.time,
    this.high,
    this.low,
    this.vol,
  });

  KLineEntity.fromJson(Map<String, dynamic> json) {
    open = (json['open'] as num).toDouble();
    high = (json['high'] as num).toDouble();
    low = (json['low'] as num).toDouble();
    close = (json['close'] as num).toDouble();
    vol = (json['vol'] as num).toDouble();
    amount = (json['amount'] as num).toDouble();
    time = (json['time'] as num).toInt();
    //兼容火币数据
    if (time == null) {
      time = ((json['id'] as num).toInt());
      if (time != null) {
        time = time! * 1000;
      }
    }
    ratio = (json['ratio'] as num).toDouble();
    change = (json['change'] as num).toDouble();
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
