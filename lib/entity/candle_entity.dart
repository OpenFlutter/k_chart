// ignore_for_file: non_constant_identifier_names,library_prefixes,unused_import,camel_case_types
mixin CandleEntity {
  late double open;
  late double high;
  late double low;
  late double close;

  List<double>? maValueList;

//  上轨线
  double? up;

//  中轨线
  double? mb;

//  下轨线
  double? dn;

  double? BOLLMA;
}
