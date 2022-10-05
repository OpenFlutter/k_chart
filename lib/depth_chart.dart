import 'dart:math';

import 'package:flutter/material.dart';

import 'package:k_chart/flutter_k_chart.dart';

class DepthChart extends StatefulWidget {
  final List<DepthEntity> bids, asks;
  final int fixedLength;
  final Color? buyPathColor;
  final Color? sellPathColor;
  final ChartColors chartColors;

  DepthChart(
    this.bids,
    this.asks,
    this.chartColors, {
    this.fixedLength = 2,
    this.buyPathColor,
    this.sellPathColor,
  });

  @override
  _DepthChartState createState() => _DepthChartState();
}

class _DepthChartState extends State<DepthChart> {
  Offset? pressOffset;
  bool isLongPress = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        pressOffset = details.localPosition;
        isLongPress = true;
        setState(() {});
      },
      onLongPressMoveUpdate: (details) {
        pressOffset = details.localPosition;
        isLongPress = true;
        setState(() {});
      },
      onTap: () {
        if (isLongPress) {
          isLongPress = false;
          setState(() {});
        }
      },
      child: CustomPaint(
        size: Size(double.infinity, double.infinity),
        painter: DepthChartPainter(
            widget.bids,
            widget.asks,
            pressOffset,
            isLongPress,
            widget.fixedLength,
            widget.buyPathColor,
            widget.sellPathColor,
            widget.chartColors),
      ),
    );
  }
}

class DepthChartPainter extends CustomPainter {
  //买入//卖出
  List<DepthEntity>? mBuyData, mSellData;
  Offset? pressOffset;
  bool isLongPress;
  int? fixedLength;
  Color? mBuyPathColor, mSellPathColor;
  ChartColors chartColors;

  double mPaddingBottom = 18.0;
  double mWidth = 0.0, mDrawHeight = 0.0, mDrawWidth = 0.0;
  double? mBuyPointWidth, mSellPointWidth;

  //最大的委托量
  double? mMaxVolume, mMultiple;

  //右侧绘制个数
  int mLineCount = 4;

  Path? mBuyPath, mSellPath;

  //买卖出区域边线绘制画笔  //买卖出取悦绘制画笔
  Paint? mBuyLinePaint,
      mSellLinePaint,
      mBuyPathPaint,
      mSellPathPaint,
      selectPaint,
      selectBorderPaint;

  DepthChartPainter(
      this.mBuyData,
      this.mSellData,
      this.pressOffset,
      this.isLongPress,
      this.fixedLength,
      this.mBuyPathColor,
      this.mSellPathColor,
      this.chartColors) {
    mBuyLinePaint ??= Paint()
      ..isAntiAlias = true
      ..color = this.chartColors.depthBuyColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    mSellLinePaint ??= Paint()
      ..isAntiAlias = true
      ..color = this.chartColors.depthSellColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    mBuyPathPaint ??= Paint()
      ..isAntiAlias = true
      ..color = (mBuyPathColor == null
          ? this.chartColors.depthBuyColor.withOpacity(0.2)
          : mBuyPathColor)!;
    mSellPathPaint ??= Paint()
      ..isAntiAlias = true
      ..color = (mSellPathColor == null
          ? this.chartColors.depthSellColor.withOpacity(0.2)
          : mSellPathColor)!;
    mBuyPath ??= Path();
    mSellPath ??= Path();
    init();
  }

  void init() {
    if (mBuyData == null ||
        mBuyData!.isEmpty ||
        mSellData == null ||
        mSellData!.isEmpty) return;
    mMaxVolume = mBuyData![0].vol;
    mMaxVolume = max(mMaxVolume!, mSellData!.last.vol);
    mMaxVolume = mMaxVolume! * 1.05;
    mMultiple = mMaxVolume! / mLineCount;
    fixedLength ??= 2;

    selectPaint = Paint()
      ..isAntiAlias = true
      ..color = chartColors.selectFillColor;
    selectBorderPaint = Paint()
      ..isAntiAlias = true
      ..color = chartColors.selectBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (mBuyData == null ||
        mSellData == null ||
        mBuyData!.isEmpty ||
        mSellData!.isEmpty) return;
    mWidth = size.width;
    mDrawWidth = mWidth / 2;
    mDrawHeight = size.height - mPaddingBottom;
    // canvas.drawColor(Colors.green, BlendMode.srcATop);
    canvas.save();
    //绘制买入区域
    drawBuy(canvas);
    //绘制卖出区域
    drawSell(canvas);

    //绘制界面相关文案
    drawText(canvas);
    canvas.restore();
  }

  void drawBuy(Canvas canvas) {
    mBuyPointWidth =
        (mDrawWidth / (mBuyData!.length - 1 == 0 ? 1 : mBuyData!.length - 1));
    mBuyPath!.reset();
    double x;
    double y;
    for (int i = 0; i < mBuyData!.length; i++) {
      if (i == 0) {
        mBuyPath!.moveTo(0, getY(mBuyData![0].vol));
      }
      x = mBuyPointWidth! * i;
      y = getY(mBuyData![i].vol);
      if (i >= 1) {
        canvas.drawLine(
            Offset(mBuyPointWidth! * (i - 1), getY(mBuyData![i - 1].vol)),
            Offset(x, y),
            mBuyLinePaint!);
      }
      if (i != mBuyData!.length - 1) {
        mBuyPath!.quadraticBezierTo(
            x, y, mBuyPointWidth! * (i + 1), getY(mBuyData![i + 1].vol));
      } else {
        if (i == 0) {
          mBuyPath!.lineTo(mDrawWidth, y);
          mBuyPath!.lineTo(mDrawWidth, mDrawHeight);
          mBuyPath!.lineTo(0, mDrawHeight);
        } else {
          mBuyPath!.quadraticBezierTo(x, y, x, mDrawHeight);
          mBuyPath!.quadraticBezierTo(x, mDrawHeight, 0, mDrawHeight);
        }
        mBuyPath!.close();
      }
    }
    canvas.drawPath(mBuyPath!, mBuyPathPaint!);
  }

  void drawSell(Canvas canvas) {
    mSellPointWidth =
        (mDrawWidth / (mSellData!.length - 1 == 0 ? 1 : mSellData!.length - 1));
    mSellPath!.reset();
    double x;
    double y;
    for (int i = 0; i < mSellData!.length; i++) {
      if (i == 0) {
        mSellPath!.moveTo(mDrawWidth, getY(mSellData![0].vol));
      }
      x = (mSellPointWidth! * i) + mDrawWidth;
      y = getY(mSellData![i].vol);
      if (i >= 1) {
        canvas.drawLine(
            Offset((mSellPointWidth! * (i - 1)) + mDrawWidth,
                getY(mSellData![i - 1].vol)),
            Offset(x, y),
            mSellLinePaint!);
      }
      if (i != mSellData!.length - 1) {
        mSellPath!.quadraticBezierTo(
            x,
            y,
            (mSellPointWidth! * (i + 1)) + mDrawWidth,
            getY(mSellData![i + 1].vol));
      } else {
        if (i == 0) {
          mSellPath!.lineTo(mWidth, y);
          mSellPath!.lineTo(mWidth, mDrawHeight);
          mSellPath!.lineTo(mDrawWidth, mDrawHeight);
        } else {
          mSellPath!.quadraticBezierTo(mWidth, y, x, mDrawHeight);
          mSellPath!.quadraticBezierTo(x, mDrawHeight, mDrawWidth, mDrawHeight);
        }
        mSellPath!.close();
      }
    }
    canvas.drawPath(mSellPath!, mSellPathPaint!);
  }

  // int? mLastPosition;

  void drawText(Canvas canvas) {
    double value;
    String str;
    for (int j = 0; j < mLineCount; j++) {
      value = mMaxVolume! - mMultiple! * j;
      str = value.toStringAsFixed(fixedLength!);
      var tp = getTextPainter(str);
      tp.layout();
      tp.paint(
          canvas,
          Offset(
              mWidth - tp.width, mDrawHeight / mLineCount * j + tp.height / 2));
    }

    var startText = mBuyData!.first.price.toStringAsFixed(fixedLength!);
    TextPainter startTP = getTextPainter(startText);
    startTP.layout();
    startTP.paint(canvas, Offset(0, getBottomTextY(startTP.height)));

    double centerPrice = (mBuyData!.last.price + mSellData!.first.price) / 2;

    var center = centerPrice.toStringAsFixed(fixedLength!);
    TextPainter centerTP = getTextPainter(center);
    centerTP.layout();
    centerTP.paint(
        canvas,
        Offset(
            mDrawWidth - centerTP.width / 2, getBottomTextY(centerTP.height)));

    var endText = mSellData!.last.price.toStringAsFixed(fixedLength!);
    TextPainter endTP = getTextPainter(endText);
    endTP.layout();
    endTP.paint(
        canvas, Offset(mWidth - endTP.width, getBottomTextY(endTP.height)));

    var leftHalfText = ((mBuyData!.first.price + centerPrice) / 2)
        .toStringAsFixed(fixedLength!);
    TextPainter leftHalfTP = getTextPainter(leftHalfText);
    leftHalfTP.layout();
    leftHalfTP.paint(
        canvas,
        Offset((mDrawWidth - leftHalfTP.width) / 2,
            getBottomTextY(leftHalfTP.height)));

    var rightHalfText = ((mSellData!.last.price + centerPrice) / 2)
        .toStringAsFixed(fixedLength!);
    TextPainter rightHalfTP = getTextPainter(rightHalfText);
    rightHalfTP.layout();
    rightHalfTP.paint(
        canvas,
        Offset((mDrawWidth + mWidth - rightHalfTP.width) / 2,
            getBottomTextY(rightHalfTP.height)));

    if (isLongPress == true) {
      if (pressOffset!.dx <= mDrawWidth) {
        int index = _indexOfTranslateX(
            pressOffset!.dx, 0, mBuyData!.length - 1, getBuyX);
        drawSelectView(canvas, index, true);
      } else {
        int index = _indexOfTranslateX(
            pressOffset!.dx, 0, mSellData!.length - 1, getSellX);
        drawSelectView(canvas, index, false);
      }
    }
  }

  void drawSelectView(Canvas canvas, int index, bool isLeft) {
    DepthEntity entity = isLeft ? mBuyData![index] : mSellData![index];
    double dx = isLeft ? getBuyX(index) : getSellX(index);

    double radius = 8.0;
    if (dx < mDrawWidth) {
      canvas.drawCircle(Offset(dx, getY(entity.vol)), radius / 3,
          mBuyLinePaint!..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(dx, getY(entity.vol)), radius,
          mBuyLinePaint!..style = PaintingStyle.stroke);
    } else {
      canvas.drawCircle(Offset(dx, getY(entity.vol)), radius / 3,
          mSellLinePaint!..style = PaintingStyle.fill);
      canvas.drawCircle(Offset(dx, getY(entity.vol)), radius,
          mSellLinePaint!..style = PaintingStyle.stroke);
    }

    //画底部
    TextPainter priceTP =
        getTextPainter(entity.price.toStringAsFixed(fixedLength!));
    priceTP.layout();
    double left;
    if (dx <= priceTP.width / 2) {
      left = 0;
    } else if (dx >= mWidth - priceTP.width / 2) {
      left = mWidth - priceTP.width;
    } else {
      left = dx - priceTP.width / 2;
    }
    Rect bottomRect = Rect.fromLTRB(left - 3, mDrawHeight + 3,
        left + priceTP.width + 3, mDrawHeight + mPaddingBottom);
    canvas.drawRect(bottomRect, selectPaint!);
    canvas.drawRect(bottomRect, selectBorderPaint!);
    priceTP.paint(
        canvas,
        Offset(bottomRect.left + (bottomRect.width - priceTP.width) / 2,
            bottomRect.top + (bottomRect.height - priceTP.height) / 2));
    //画左边
    TextPainter amountTP =
        getTextPainter(entity.vol.toStringAsFixed(fixedLength!));
    amountTP.layout();
    double y = getY(entity.vol);
    double rightRectTop;
    if (y <= amountTP.height / 2) {
      rightRectTop = 0;
    } else if (y >= mDrawHeight - amountTP.height / 2) {
      rightRectTop = mDrawHeight - amountTP.height;
    } else {
      rightRectTop = y - amountTP.height / 2;
    }
    Rect rightRect = Rect.fromLTRB(mWidth - amountTP.width - 6,
        rightRectTop - 3, mWidth, rightRectTop + amountTP.height + 3);
    canvas.drawRect(rightRect, selectPaint!);
    canvas.drawRect(rightRect, selectBorderPaint!);
    amountTP.paint(
        canvas,
        Offset(rightRect.left + (rightRect.width - amountTP.width) / 2,
            rightRect.top + (rightRect.height - amountTP.height) / 2));
  }

  ///二分查找当前值的index
  int _indexOfTranslateX(double translateX, int start, int end, Function getX) {
    if (end == start || end == -1) {
      return start;
    }
    if (end - start == 1) {
      double startValue = getX(start);
      double endValue = getX(end);
      return (translateX - startValue).abs() < (translateX - endValue).abs()
          ? start
          : end;
    }
    int mid = start + (end - start) ~/ 2;
    double midValue = getX(mid);
    if (translateX < midValue) {
      return _indexOfTranslateX(translateX, start, mid, getX);
    } else if (translateX > midValue) {
      return _indexOfTranslateX(translateX, mid, end, getX);
    } else {
      return mid;
    }
  }

  double getBuyX(int position) => position * mBuyPointWidth!;

  double getSellX(int position) => position * mSellPointWidth! + mDrawWidth;

  getTextPainter(String text, [Color color = Colors.white]) => TextPainter(
      text:
          TextSpan(text: "$text", style: TextStyle(color: color, fontSize: 10)),
      textDirection: TextDirection.ltr);

  double getBottomTextY(double textHeight) =>
      (mPaddingBottom - textHeight) / 2 + mDrawHeight;

  double getY(double volume) =>
      mDrawHeight - (mDrawHeight) * volume / mMaxVolume!;

  @override
  bool shouldRepaint(DepthChartPainter oldDelegate) {
//    return oldDelegate.mBuyData != mBuyData ||
//        oldDelegate.mSellData != mSellData ||
//        oldDelegate.isLongPress != isLongPress ||
//        oldDelegate.pressOffset != pressOffset;
    return true;
  }
}
