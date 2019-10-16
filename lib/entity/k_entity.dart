import 'candle_entity.dart';
import 'kdj_entity.dart';
import 'macd_entity.dart';
import 'rsi_entity.dart';
import 'rw_entity.dart';
import 'volume_entity.dart';

class KEntity with CandleEntity, VolumeEntity, KDJEntity, RSIEntity, WREntity, MACDEntity {}
