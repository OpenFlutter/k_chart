import 'dart:async' show StreamSink;

import 'package:flutter/material.dart';
import 'package:k_chart/k_chart_widget.dart';
import 'package:k_chart/utils/number_util.dart';
import '../entity/k_line_entity.dart';
import '../utils/date_format_util.dart';
import '../entity/info_window_entity.dart';

import 'base_chart_painter.dart';
import 'base_chart_renderer.dart';
import 'main_renderer.dart';
import 'secondary_renderer.dart';
import 'vol_renderer.dart';

class ChartPainter extends BaseChartPainter {
  static get maxScrollX => BaseChartPainter.maxScrollX;

  BaseChartRenderer mMainRenderer, mVolRenderer, mSecondaryRenderer;
  StreamSink<InfoWindowEntity> sink;
  Color upColor, dnColor;
  Color ma5Color, ma10Color, ma30Color;
  Color volColor;
  Color macdColor, difColor, deaColor, jColor;
  List<Color> bgColor;
  int fixedLength;
  List<int> maDayList;
  Color selectionLineColor;
  Color lineChartColor;
  Color lineChartFillColor;
  Color maxMinColor;
  double topPadding, bottomPadding, chartVerticalPadding;
  final List<String> datetimeFormat;
  final KChartLanguage language;
  final String Function(double) priceFormatter;
  final ChartStyle style;

  ChartPainter({
    @required datas,
    @required scaleX,
    @required scrollX,
    @required isLongPass,
    @required selectX,
    @required this.language,
    @required this.style,
    mainState,
    volHidden,
    secondaryState,
    this.sink,
    bool isLine,
    this.bgColor,
    this.fixedLength,
    this.maDayList,
    this.selectionLineColor,
    this.lineChartColor,
    this.lineChartFillColor,
    this.maxMinColor,
    this.topPadding,
    this.bottomPadding,
    this.chartVerticalPadding = 5,
    this.datetimeFormat,
    int gridRows = 4,
    int gridColumns = 5,
    this.priceFormatter,
  })  : assert(bgColor == null || bgColor.length >= 2),
        super(
          datas: datas,
          scaleX: scaleX,
          scrollX: scrollX,
          isLongPress: isLongPass,
          selectX: selectX,
          topPadding: topPadding,
          bottomPadding: bottomPadding,
          mainState: mainState,
          volHidden: volHidden,
          secondaryState: secondaryState,
          isLine: isLine,
          dateFormat: datetimeFormat,
          gridRows: gridRows,
          gridColumns: gridColumns,
          style: style,
        );

  @override
  void initChartRenderer() {
    if (fixedLength == null) {
      if (datas == null || datas.isEmpty) {
        fixedLength = 2;
      } else {
        var t = datas[0];
        fixedLength = NumberUtil.getMaxDecimalLength(
          t.open,
          t.close,
          t.high,
          t.low,
        );
      }
    }

    mMainRenderer ??= MainRenderer(
      mainRect: mMainRect,
      maxValue: mMainMaxValue,
      minValue: mMainMinValue,
      topPadding: topPadding,
      contentPadding: chartVerticalPadding,
      state: mainState,
      isLine: isLine,
      fixedLength: fixedLength,
      lineChartColor: lineChartColor,
      lineChartFillColor: lineChartFillColor,
      maDayList: maDayList,
      priceFormatter: priceFormatter,
      priceLabelBackgroundColor: Color(0xe1f5f5f5),
      style: style,
    );

    if (mVolRect != null) {
      mVolRenderer ??= VolRenderer(
        style,
        mVolRect,
        mVolMaxValue,
        mVolMinValue,
        mChildPadding,
        fixedLength,
      );
    }

    if (mSecondaryRect != null)
      mSecondaryRenderer ??= SecondaryRenderer(
        style,
        mSecondaryRect,
        mSecondaryMaxValue,
        mSecondaryMinValue,
        mChildPadding,
        secondaryState,
        fixedLength,
      );
  }

  @override
  void drawBg(Canvas canvas, Size size) {
    final mBgPaint = Paint();
    final mBgGradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: bgColor ?? [Color(0xff18191d), Color(0xff18191d)],
    );

    if (mMainRect != null) {
      Rect mainRect = Rect.fromLTRB(
        0,
        0,
        mMainRect.width,
        mMainRect.height + topPadding,
      );

      canvas.drawRect(
        mainRect,
        mBgPaint..shader = mBgGradient.createShader(mainRect),
      );
    }

    if (mVolRect != null) {
      Rect volRect = Rect.fromLTRB(
        0,
        mVolRect.top - mChildPadding,
        mVolRect.width,
        mVolRect.bottom,
      );

      canvas.drawRect(
        volRect,
        mBgPaint..shader = mBgGradient.createShader(volRect),
      );
    }

    if (mSecondaryRect != null) {
      Rect secondaryRect = Rect.fromLTRB(0, mSecondaryRect.top - mChildPadding,
          mSecondaryRect.width, mSecondaryRect.bottom);
      canvas.drawRect(secondaryRect,
          mBgPaint..shader = mBgGradient.createShader(secondaryRect));
    }
    Rect dateRect =
        Rect.fromLTRB(0, size.height - bottomPadding, size.width, size.height);
    canvas.drawRect(
        dateRect, mBgPaint..shader = mBgGradient.createShader(dateRect));
  }

  @override
  void drawGrid(canvas) {
    mMainRenderer?.drawGrid(canvas, gridRows, gridColumns);
    mVolRenderer?.drawGrid(canvas, gridRows, gridColumns);
    mSecondaryRenderer?.drawGrid(canvas, gridRows, gridColumns);
  }

  @override
  void drawChart(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(mTranslateX * scaleX, 0.0);
    canvas.scale(scaleX, 1.0);
    for (int i = mStartIndex; datas != null && i <= mStopIndex; i++) {
      KLineEntity curPoint = datas[i];
      if (curPoint == null) continue;
      KLineEntity lastPoint = i == 0 ? curPoint : datas[i - 1];
      double curX = getX(i);
      double lastX = i == 0 ? curX : getX(i - 1);

      mMainRenderer?.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
      mVolRenderer?.drawChart(lastPoint, curPoint, lastX, curX, size, canvas);
      mSecondaryRenderer?.drawChart(
          lastPoint, curPoint, lastX, curX, size, canvas);
    }

    if (isLongPress == true) drawCrossLine(canvas, size);
    canvas.restore();
  }

  @override
  void drawRightText(canvas) {
    var textStyle = getTextStyle(ChartColors.defaultTextColor);
    mMainRenderer?.drawRightText(canvas, textStyle, gridRows);
    mVolRenderer?.drawRightText(canvas, textStyle, gridRows);
    mSecondaryRenderer?.drawRightText(canvas, textStyle, gridRows);
  }

  @override
  void drawDate(Canvas canvas, Size size) {
    double columnSpace = size.width / gridColumns;
    double startX = getX(mStartIndex) - style.pointWidth / 2;
    double stopX = getX(mStopIndex) + style.pointWidth / 2;
    double y = 0.0;

    for (var i = 1; i <= gridColumns; ++i) {
      double translateX = xToTranslateX(columnSpace * i);
      if (translateX >= startX && translateX <= stopX) {
        int index = indexOfTranslateX(translateX);
        if (datas[index] == null) continue;
        TextPainter tp = getTextPainter(getDate(datas[index].time));
        y = size.height - (bottomPadding - tp.height) / 2 - tp.height;
        tp.paint(canvas, Offset(columnSpace * i - tp.width / 2, y));
      }
    }

//    double translateX = xToTranslateX(0);
//    if (translateX >= startX && translateX <= stopX) {
//      TextPainter tp = getTextPainter(getDate(datas[mStartIndex].id));
//      tp.paint(canvas, Offset(0, y));
//    }
//    translateX = xToTranslateX(size.width);
//    if (translateX >= startX && translateX <= stopX) {
//      TextPainter tp = getTextPainter(getDate(datas[mStopIndex].id));
//      tp.paint(canvas, Offset(size.width - tp.width, y));
//    }
  }

  final selectPointPaint = Paint()
    ..isAntiAlias = true
    ..strokeWidth = 0.5
    ..color = ChartColors.selectFillColor;

  final selectorBorderPaint = Paint()
    ..isAntiAlias = true
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke
    ..color = ChartColors.selectBorderColor;

  @override
  void drawCrossLineText(Canvas canvas, Size size) {
    var index = calculateSelectedX(selectX);
    KLineEntity point = getItem(index);

    TextPainter tp = getTextPainter(point.close, Colors.white);
    double textHeight = tp.height;
    double textWidth = tp.width;

    double w1 = 5;
    double w2 = 3;
    double r = textHeight / 2 + w2;
    double y = getMainY(point.close);
    double x;
    bool isLeft = false;
    if (translateXtoX(getX(index)) < mWidth / 2) {
      isLeft = false;
      x = 1;
      Path path = new Path();
      path.moveTo(x, y - r);
      path.lineTo(x, y + r);
      path.lineTo(textWidth + 2 * w1, y + r);
      path.lineTo(textWidth + 2 * w1 + w2, y);
      path.lineTo(textWidth + 2 * w1, y - r);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1, y - textHeight / 2));
    } else {
      isLeft = true;
      x = mWidth - textWidth - 1 - 2 * w1 - w2;
      Path path = new Path();
      path.moveTo(x, y);
      path.lineTo(x + w2, y + r);
      path.lineTo(mWidth - 2, y + r);
      path.lineTo(mWidth - 2, y - r);
      path.lineTo(x + w2, y - r);
      path.close();
      canvas.drawPath(path, selectPointPaint);
      canvas.drawPath(path, selectorBorderPaint);
      tp.paint(canvas, Offset(x + w1 + w2, y - textHeight / 2));
    }

    TextPainter dateTp = getTextPainter(getDate(point.time), Colors.white);
    textWidth = dateTp.width;
    r = textHeight / 2;
    x = translateXtoX(getX(index));
    y = size.height - bottomPadding;

    if (x < textWidth + 2 * w1) {
      x = 1 + textWidth / 2 + w1;
    } else if (mWidth - x < textWidth + 2 * w1) {
      x = mWidth - 1 - textWidth / 2 - w1;
    }
    double baseLine = textHeight / 2;
    canvas.drawRect(
        Rect.fromLTRB(x - textWidth / 2 - w1, y, x + textWidth / 2 + w1,
            y + baseLine + r),
        selectPointPaint);
    canvas.drawRect(
        Rect.fromLTRB(x - textWidth / 2 - w1, y, x + textWidth / 2 + w1,
            y + baseLine + r),
        selectorBorderPaint);

    dateTp.paint(canvas, Offset(x - textWidth / 2, y));
    //长按显示这条数据详情
    sink?.add(InfoWindowEntity(point, isLeft));
  }

  @override
  void drawText(Canvas canvas, KLineEntity data, double x) {
    //长按显示按中的数据
    if (isLongPress) {
      var index = calculateSelectedX(selectX);
      data = getItem(index);
    }
    //松开显示最后一条数据
    mMainRenderer?.drawText(canvas, data, x);
    mVolRenderer?.drawText(canvas, data, x);
    mSecondaryRenderer?.drawText(canvas, data, x);
  }

  @override
  void drawMaxAndMin(Canvas canvas) {
    if (isLine == true) return;

    double x = translateXtoX(getX(mMainMinIndex));
    double y = getMainY(mMainLowMinValue);

    final lowMinValue = priceFormatter?.call(mMainLowMinValue) ??
        mMainLowMinValue.toStringAsFixed(fixedLength);
    final highMaxValue = priceFormatter?.call(mMainHighMaxValue) ??
        mMainHighMaxValue.toStringAsFixed(fixedLength);

    if (x < mWidth / 2) {
      final tp = getTextPainter("── $lowMinValue", maxMinColor);
      tp.paint(canvas, Offset(x, y - tp.height / 2));
    } else {
      final tp = getTextPainter("$lowMinValue ──", maxMinColor);
      tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    }

    x = translateXtoX(getX(mMainMaxIndex));
    y = getMainY(mMainHighMaxValue);

    if (x < mWidth / 2) {
      final tp = getTextPainter("── $highMaxValue", maxMinColor);
      tp.paint(canvas, Offset(x, y - tp.height / 2));
    } else {
      final tp = getTextPainter("$highMaxValue ──", maxMinColor);
      tp.paint(canvas, Offset(x - tp.width, y - tp.height / 2));
    }
  }

  ///画交叉线
  void drawCrossLine(Canvas canvas, Size size) {
    var index = calculateSelectedX(selectX);
    KLineEntity point = getItem(index);

    final paintY = Paint()
      ..color = selectionLineColor
      ..strokeWidth = style.vCrossLineWidth
      ..isAntiAlias = true;

    double x = getX(index);
    double y = getMainY(point.close);
    // k线图竖线
    canvas.drawLine(
        Offset(x, topPadding), Offset(x, size.height - bottomPadding), paintY);

    final paintX = Paint()
      ..color = selectionLineColor
      ..strokeWidth = style.hCrossLineWidth
      ..isAntiAlias = true;

    // k线图横线
    canvas.drawLine(Offset(-mTranslateX, y),
        Offset(-mTranslateX + mWidth / scaleX, y), paintX);
    canvas.drawCircle(Offset(x, y), 2.0, paintX);
  }

  TextPainter getTextPainter(text, [color = ChartColors.defaultTextColor]) {
    final style = getTextStyle(color);
    final span = TextSpan(text: "$text", style: style);
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);

    tp.layout();
    return tp;
  }

  String getDate(int date) =>
      dateFormat(DateTime.fromMillisecondsSinceEpoch(date), mFormats, language);

  double getMainY(double y) => mMainRenderer?.getY(y) ?? 0.0;
}
