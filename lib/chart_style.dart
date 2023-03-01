import 'package:flutter/material.dart' show Color;

class ChartColors {
  List<Color> bgColor = [Color(0xffffffff), Color(0xffffffff)];

  Color kLineColor = Color(0xff4C86CD); ///
  Color lineFillColor = Color(0x554C86CD); ///
  Color lineFillInsideColor = Color(0x00000000); ///
  Color ma5Color = Color(0xffE5B767);
  Color ma10Color = Color(0xff1FD1AC);
  Color ma30Color = Color(0xffB48CE3);
  Color upColor = Color(0xFF14AD8F);
  Color dnColor = Color(0xFFD5405D);
  Color volColor = Color(0xff2f8fd5);

  Color macdColor = Color(0xff2f8fd5);
  Color difColor = Color(0xffE5B767);
  Color deaColor = Color(0xff1FD1AC);

  Color kColor = Color(0xffE5B767);
  Color dColor = Color(0xff1FD1AC);
  Color jColor = Color(0xffB48CE3);
  Color rsiColor = Color(0xffE5B767);

  Color defaultTextColor = Color(0xFF909196);

  Color nowPriceUpColor = Color(0xFF14AD8F);
  Color nowPriceDnColor = Color(0xFFD5405D);
  Color nowPriceTextColor = Color(0xffffffff);

  ///depth color
  Color depthBuyColor = Color(0xFF14AD8F);
  Color depthSellColor = Color(0xFFD5405D);

  ///value border color after selection
  Color selectBorderColor = Color(0xFF222223);

  ///background color when value selected
  Color selectFillColor = Color(0xffffffff);

  ///color of grid
  Color gridColor = Color(0xFFD1D3DB);

  ///color of annotation content
  Color infoWindowNormalColor = Color(0xFF222223);
  Color infoWindowTitleColor = Color(0xFF222223); //0xFF707070
  Color infoWindowUpColor = Color(0xFF14AD8F);
  Color infoWindowDnColor = Color(0xFFD5405D);

  Color hCrossColor = Color(0xFF222223);
  Color vCrossColor = Color(0x28424652);
  Color crossTextColor = Color(0xFF222223);

  ///The color of the maximum and minimum values in the current display
  Color maxColor = Color(0xFF222223);
  Color minColor = Color(0xFF222223);

  Color getMAColor(int index) {
    switch (index % 3) {
      case 1:
        return ma10Color;
      case 2:
        return ma30Color;
      default:
        return ma5Color;
    }
  }
}

class ChartStyle {
  double topPadding = 30.0;

  double bottomPadding = 20.0;

  double childPadding = 12.0;

  ///point-to-point distance
  double pointWidth = 11.0;

  ///candle width
  double candleWidth = 8.5;
  double candleLineWidth = 1.0;

  ///vol column width
  double volWidth = 8.5;

  ///macd column width
  double macdWidth = 1.2;

  ///vertical-horizontal cross line width
  double vCrossWidth = 8.5;
  double hCrossWidth = 0.5;

  ///(line length - space line - thickness) of the current price
  double nowPriceLineLength = 4.5;
  double nowPriceLineSpan = 3.5;
  double nowPriceLineWidth = 1;

  int gridRows = 4;
  int gridColumns = 4;

  ///customize the time below
  List<String>? dateTimeFormat;
}
