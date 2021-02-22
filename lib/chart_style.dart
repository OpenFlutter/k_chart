import 'package:flutter/material.dart' show Color;

class ChartColors {
  ChartColors._();

  static const Color ma5Color = Color(0xffC9B885);
  static const Color ma10Color = Color(0xff6CB0A6);
  static const Color ma30Color = Color(0xff9979C6);
  static const Color upColor = Color(0xff76C42D);
  static const Color dnColor = Color(0xffFD4762);
  static const Color volColor = Color(0xff4729AE);

  static const Color macdColor = Color(0xff4729AE);
  static const Color difColor = Color(0xffC9B885);
  static const Color deaColor = Color(0xff6CB0A6);

  static const Color kColor = Color(0xffC9B885);
  static const Color dColor = Color(0xff6CB0A6);
  static const Color jColor = Color(0xff9979C6);
  static const Color rsiColor = Color(0xffC9B885);

  static const Color defaultTextColor = Color(0xff60738E);

  static const Color depthBuyColor = Color(0xff60A893);
  static const Color depthSellColor = Color(0xffC15866);

  static const Color selectBorderColor = Color(0xff6C7A86);
  static const Color selectFillColor = Color(0xff131D2B);

  static Color getMAColor(int index) {
    Color maColor = ma5Color;
    switch (index % 3) {
      case 0:
        maColor = ma5Color;
        break;
      case 1:
        maColor = ma10Color;
        break;
      case 2:
        maColor = ma30Color;
        break;
    }
    return maColor;
  }
}

class ChartStyle {
  const ChartStyle({
    this.pointWidth,
    this.candleWidth,
    this.candleLineWidth,
    this.volWidth,
    this.macdWidth,
    this.vCrossWidth,
    this.hCrossWidth,
  })  : assert(pointWidth != null),
        assert(candleWidth != null),
        assert(candleLineWidth != null),
        assert(volWidth != null),
        assert(macdWidth != null),
        assert(vCrossWidth != null),
        assert(hCrossWidth != null);

  final double pointWidth;
  final double candleWidth;
  final double candleLineWidth;
  final double volWidth;
  final double macdWidth;
  final double vCrossWidth;
  final double hCrossWidth;

  static const defaultStyle = ChartStyle(
    pointWidth: 20,
    candleWidth: 12.5,
    candleLineWidth: 1.5,
    volWidth: 8.5,
    macdWidth: 3,
    vCrossWidth: 8.5,
    hCrossWidth: 0.5,
  );

  ChartStyle copyWith({
    double pointWidth,
    double candleWidth,
    double candleLineWidth,
    double volWidth,
    double macdWidth,
    double vCrossWidth,
    double hCrossWidth,
  }) {
    return ChartStyle(
      pointWidth: pointWidth ?? this.pointWidth,
      candleWidth: candleWidth ?? this.candleWidth,
      candleLineWidth: candleLineWidth ?? this.candleLineWidth,
      volWidth: volWidth ?? this.volWidth,
      macdWidth: macdWidth ?? this.macdWidth,
      vCrossWidth: vCrossWidth ?? this.vCrossWidth,
      hCrossWidth: hCrossWidth ?? this.hCrossWidth,
    );
  }
}
