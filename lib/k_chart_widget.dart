import 'dart:async';

import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'chart_style.dart';
import 'entity/info_window_entity.dart';
import 'entity/k_line_entity.dart';
import 'renderer/chart_painter.dart';
import 'utils/date_format_util.dart';

enum MainState { MA, BOLL, NONE }
enum SecondaryState { MACD, KDJ, RSI, WR, NONE }

class TimeFormat {
  static const List<String> YEAR_MONTH_DAY = [yyyy, '-', mm, '-', dd];
  static const List<String> YEAR_MONTH_DAY_WITH_HOUR = [
    yyyy,
    '-',
    mm,
    '-',
    dd,
    ' ',
    HH,
    ':',
    nn
  ];
}

enum KChartLanguage { russian, english }

enum InfoWindowElement {
  date,
  open,
  high,
  low,
  close,
  change,
  changePercent,
  amount
}

const defaultInfoWindowElements = [
  InfoWindowElement.date,
  InfoWindowElement.open,
  InfoWindowElement.high,
  InfoWindowElement.low,
  InfoWindowElement.close,
  InfoWindowElement.changePercent,
];

class KChartWidget extends StatefulWidget {
  final List<KLineEntity> datas;
  final MainState mainState;
  final bool volHidden;
  final SecondaryState secondaryState;
  final bool isLine;
  final KChartLanguage language;
  final Function(bool) onLoadMore;
  final List<Color> bgColor;
  final int fixedLength;
  final List<int> maDayList;
  final int flingTime;
  final double flingRatio;
  final Curve flingCurve;
  final Function(bool) isOnDrag;
  final Color selectionLineColor;
  final Color lineChartColor;
  final Color lineChartFillColor;
  final Color maxMinColor;
  final double topPadding, bottomPadding, chartVerticalPadding;
  final List<String> dateFormat;
  final List<String> infoWindowDateFormat;
  final List<InfoWindowElement> infoWindowElements;
  final int gridRows, gridColumns;
  final String Function(double) priceFormatter;

  KChartWidget(
    this.datas, {
    this.mainState = MainState.MA,
    this.secondaryState = SecondaryState.MACD,
    this.volHidden = false,
    this.isLine,
    this.language,
    this.onLoadMore,
    this.bgColor,
    this.fixedLength,
    this.maDayList = const [5, 10, 20],
    this.flingTime = 600,
    this.flingRatio = 0.5,
    this.flingCurve = Curves.decelerate,
    this.isOnDrag,
    this.selectionLineColor = Colors.black,
    this.lineChartColor = Colors.black,
    this.lineChartFillColor = Colors.black45,
    this.maxMinColor = Colors.black87,
    this.topPadding = 0.0,
    this.bottomPadding = 20.0,
    this.chartVerticalPadding = 5,
    this.dateFormat,
    this.infoWindowDateFormat,
    this.infoWindowElements = defaultInfoWindowElements,
    this.gridRows = 4,
    this.gridColumns = 5,
    this.priceFormatter,
  }) : assert(maDayList != null);

  @override
  _KChartWidgetState createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget>
    with TickerProviderStateMixin {
  double mScaleX = 1.0, mScrollX = 0.0, mSelectX = 0.0;
  StreamController<InfoWindowEntity> mInfoWindowStream;
  double mWidth = 0;
  AnimationController _controller;
  Animation<double> aniX;

  double getMinScrollX() {
    return mScaleX;
  }

  double _lastScale = 1.0;
  bool isScale = false, isDrag = false, isLongPress = false;

  @override
  void initState() {
    super.initState();
    mInfoWindowStream = StreamController<InfoWindowEntity>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mWidth = MediaQuery.of(context).size.width;
  }

  @override
  void dispose() {
    mInfoWindowStream?.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.datas == null || widget.datas.isEmpty) {
      mScrollX = mSelectX = 0.0;
      mScaleX = 1.0;
    }

    return ClipRRect(
      child: Padding(
        padding: const EdgeInsets.all(0.5),
        child: GestureDetector(
          onHorizontalDragDown: (details) {
            _stopAnimation();
            _onDragChanged(true);
          },
          onHorizontalDragUpdate: (details) {
            if (isScale || isLongPress) return;
            mScrollX = (details.primaryDelta / mScaleX + mScrollX)
                .clamp(0.0, ChartPainter.maxScrollX);
            notifyChanged();
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            var velocity = details.velocity.pixelsPerSecond.dx;
            _onFling(velocity);
          },
          onHorizontalDragCancel: () => _onDragChanged(false),
          onScaleStart: (_) {
            isScale = true;
          },
          onScaleUpdate: (details) {
            if (isDrag || isLongPress) return;
            mScaleX = (_lastScale * details.scale).clamp(0.5, 2.2);
            notifyChanged();
          },
          onScaleEnd: (_) {
            isScale = false;
            _lastScale = mScaleX;
          },
          onLongPressStart: (details) {
            isLongPress = true;
            if (mSelectX != details.globalPosition.dx) {
              mSelectX = details.globalPosition.dx;
              notifyChanged();
            }
          },
          onLongPressMoveUpdate: (details) {
            if (mSelectX != details.globalPosition.dx) {
              mSelectX = details.globalPosition.dx;
              notifyChanged();
            }
          },
          onLongPressEnd: (details) {
            isLongPress = false;
            mInfoWindowStream?.sink?.add(null);
            notifyChanged();
          },
          child: Stack(
            children: <Widget>[
              CustomPaint(
                size: Size(double.infinity, double.infinity),
                painter: ChartPainter(
                  datas: widget.datas,
                  scaleX: mScaleX,
                  scrollX: mScrollX,
                  selectX: mSelectX,
                  isLongPass: isLongPress,
                  mainState: widget.mainState,
                  volHidden: widget.volHidden,
                  secondaryState: widget.secondaryState,
                  isLine: widget.isLine,
                  sink: mInfoWindowStream?.sink,
                  bgColor: widget.bgColor,
                  fixedLength: widget.fixedLength,
                  maDayList: widget.maDayList,
                  selectionLineColor: widget.selectionLineColor,
                  lineChartColor: widget.lineChartColor,
                  lineChartFillColor: widget.lineChartFillColor,
                  maxMinColor: widget.maxMinColor,
                  topPadding: widget.topPadding,
                  bottomPadding: widget.bottomPadding,
                  chartVerticalPadding: widget.chartVerticalPadding,
                  datetimeFormat: widget.dateFormat,
                  language: widget.language,
                  gridRows: widget.gridRows,
                  gridColumns: widget.gridColumns,
                  priceFormatter: widget.priceFormatter,
                ),
              ),
              _buildInfoDialog()
            ],
          ),
        ),
      ),
    );
  }

  void _stopAnimation({bool needNotify = true}) {
    if (_controller != null && _controller.isAnimating) {
      _controller.stop();
      _onDragChanged(false);
      if (needNotify) {
        notifyChanged();
      }
    }
  }

  void _onDragChanged(bool isOnDrag) {
    isDrag = isOnDrag;
    if (widget.isOnDrag != null) {
      widget.isOnDrag(isDrag);
    }
  }

  void _onFling(double x) {
    _controller = AnimationController(
      duration: Duration(milliseconds: widget.flingTime),
      vsync: this,
    );

    aniX = null;
    aniX = Tween<double>(
      begin: mScrollX,
      end: x * widget.flingRatio + mScrollX,
    ).animate(
      CurvedAnimation(parent: _controller, curve: widget.flingCurve),
    );

    aniX.addListener(() {
      mScrollX = aniX.value;
      if (mScrollX <= 0) {
        mScrollX = 0;
        if (widget.onLoadMore != null) {
          widget.onLoadMore(true);
        }
        _stopAnimation();
      } else if (mScrollX >= ChartPainter.maxScrollX) {
        mScrollX = ChartPainter.maxScrollX;
        if (widget.onLoadMore != null) {
          widget.onLoadMore(false);
        }
        _stopAnimation();
      }
      notifyChanged();
    });
    aniX.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _onDragChanged(false);
        notifyChanged();
      }
    });
    _controller.forward();
  }

  void notifyChanged() => setState(() {});

  final infoNamesEN = {
    InfoWindowElement.date: "Date",
    InfoWindowElement.open: "Open",
    InfoWindowElement.high: "High",
    InfoWindowElement.low: "Low",
    InfoWindowElement.close: "Close",
    InfoWindowElement.change: "Change",
    InfoWindowElement.changePercent: "Change%",
    InfoWindowElement.amount: "Amount"
  };

  final infoNamesRU = {
    InfoWindowElement.date: "Дата",
    InfoWindowElement.open: "Откр.",
    InfoWindowElement.high: "Макс.",
    InfoWindowElement.low: "Мин.",
    InfoWindowElement.close: "Закр.",
    InfoWindowElement.change: "Изм.",
    InfoWindowElement.changePercent: "Изм.",
    InfoWindowElement.amount: "Колич."
  };

  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowEntity>(
      stream: mInfoWindowStream?.stream,
      builder: _buildInfoWindowContent,
    );
  }

  Widget _buildInfoWindowContent(context, snapshot) {
    if (!isLongPress ||
        widget.isLine == true ||
        !snapshot.hasData ||
        snapshot.data.kLineEntity == null) return Container();

    KLineEntity e = snapshot.data.kLineEntity;
    double upDown = e.change ?? e.close - e.open;
    double upDownPercent = e.ratio ?? (upDown / e.open) * 100;
    final fixedLength = widget.fixedLength;

    final infoGrabbers = {
      InfoWindowElement.date: () => _getInfoWindowDate(e.time),
      InfoWindowElement.open: () => e.open.toStringAsFixed(fixedLength),
      InfoWindowElement.high: () => e.high.toStringAsFixed(fixedLength),
      InfoWindowElement.low: () => e.low.toStringAsFixed(fixedLength),
      InfoWindowElement.close: () => e.close.toStringAsFixed(fixedLength),
      InfoWindowElement.change: () =>
          "${upDown > 0 ? "+" : ""}${upDown.toStringAsFixed(widget.fixedLength)}",
      InfoWindowElement.changePercent: () =>
          "${upDownPercent > 0 ? "+" : ''}${upDownPercent.toStringAsFixed(2)}%",
      InfoWindowElement.amount: () => e.amount.toInt().toString(),
    };

    final infoNames = {
      KChartLanguage.english: infoNamesEN,
      KChartLanguage.russian: infoNamesRU,
    }[widget.language];

    final infos = widget.infoWindowElements //
        .map((e) => [infoGrabbers[e](), infoNames[e]])
        .toList();

    const infoWindowHeight = 130.0;

    return Container(
      margin: EdgeInsets.only(
        left: snapshot.data.isLeft ? 4 : mWidth - infoWindowHeight - 40,
        right: 4,
        top: 12,
      ),
      width: infoWindowHeight,
      decoration: BoxDecoration(
        color: ChartColors.selectFillColor,
        border: Border.all(color: ChartColors.selectBorderColor, width: 0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemCount: infos.length,
        shrinkWrap: true,
        itemBuilder: (_, i) => _buildItem(infos[i][0], infos[i][1]),
      ),
    );
  }

  Widget _buildItem(String info, String infoName) {
    Color color = Colors.white;
    if (info.startsWith("+"))
      color = Colors.green;
    else if (info.startsWith("-"))
      color = Colors.red;
    else
      color = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              "$infoName",
              style: const TextStyle(color: Color(0xFF9499A2), fontSize: 12.0),
            ),
          ),
          Text(
            info,
            style: TextStyle(
              color: color,
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String getDate(int date) {
    return dateFormat(
      DateTime.fromMillisecondsSinceEpoch(date),
      widget.dateFormat,
      widget.language,
    );
  }

  String _getInfoWindowDate(int date) {
    final format = widget.infoWindowDateFormat ?? widget.dateFormat;
    return dateFormat(
      DateTime.fromMillisecondsSinceEpoch(date),
      format,
      widget.language,
    );
  }
}
