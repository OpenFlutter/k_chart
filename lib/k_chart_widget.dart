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
  static const List<String> YEAR_MONTH_DAY_WITH_HOUR = [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn];
}

class KChartWidget extends StatefulWidget {
  final List<KLineEntity> datas;
  final MainState mainState;
  final SecondaryState secondaryState;
  final bool isLine;
  final bool isChinese;
  final List<String> timeFormat;
  //当屏幕滚动到尽头会调用，真为拉到屏幕右侧尽头，假为拉到屏幕左侧尽头
  final Function(bool) onLoadMore;
  final List<Color> bgColor;
  final int fixedLength;
  final List<int> maDayList;
  final int flingTime;
  final double flingRatio;
  final Curve flingCurve;
  final Function(bool) isOnDrag;

  KChartWidget(
    this.datas, {
    this.mainState = MainState.MA,
    this.secondaryState = SecondaryState.MACD,
    this.isLine,
    this.isChinese = true,
    this.timeFormat = TimeFormat.YEAR_MONTH_DAY,
    this.onLoadMore,
    this.bgColor,
    this.fixedLength,
    this.maDayList = const [5, 10, 20],
    this.flingTime = 600,
    this.flingRatio = 0.5,
    this.flingCurve = Curves.decelerate,
    this.isOnDrag,
  }) : assert(maDayList != null);

  @override
  _KChartWidgetState createState() => _KChartWidgetState();
}

class _KChartWidgetState extends State<KChartWidget> with TickerProviderStateMixin {
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
    return GestureDetector(
      onHorizontalDragDown: (details) {
        _stopAnimation();
        _onDragChanged(true);
      },
      onHorizontalDragUpdate: (details) {
        if (isScale || isLongPress) return;
        mScrollX = (details.primaryDelta / mScaleX + mScrollX).clamp(0.0, ChartPainter.maxScrollX);
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
                secondaryState: widget.secondaryState,
                isLine: widget.isLine,
                sink: mInfoWindowStream?.sink,
                bgColor: widget.bgColor,
                fixedLength: widget.fixedLength,
                maDayList: widget.maDayList),
          ),
          _buildInfoDialog()
        ],
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
    _controller = AnimationController(duration: Duration(milliseconds: widget.flingTime), vsync: this);
    aniX = null;
    aniX = Tween<double>(begin: mScrollX, end: x * widget.flingRatio + mScrollX).animate(CurvedAnimation(parent: _controller, curve: widget.flingCurve));
    aniX.addListener(() {
      mScrollX = aniX.value;
      if (mScrollX <= 0) {
        mScrollX = 0;
        if (widget.onLoadMore != null) {
          widget.onLoadMore(true);
        }
      } else if (mScrollX >= ChartPainter.maxScrollX) {
        mScrollX = ChartPainter.maxScrollX;
        if (widget.onLoadMore != null) {
          widget.onLoadMore(false);
        }
      }
      _stopAnimation();
      notifyChanged();
    });
    aniX.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        _onDragChanged(false);
        notifyChanged();
      }
    });
    _controller.forward();
  }

  void notifyChanged() => setState(() {});

  final List<String> infoNamesCN = ["时间", "开", "高", "低", "收", "涨跌额", "涨跌幅", "成交额"];
  final List<String> infoNamesEN = ["Date", "Open", "High", "Low", "Close", "Change", "Change%", "Amount"];
  List<String> infos;

  Widget _buildInfoDialog() {
    return StreamBuilder<InfoWindowEntity>(
        stream: mInfoWindowStream?.stream,
        builder: (context, snapshot) {
          if (!isLongPress || widget.isLine == true || !snapshot.hasData || snapshot.data.kLineEntity == null) return Container();
          KLineEntity entity = snapshot.data.kLineEntity;
          double upDown = entity.change ?? entity.close - entity.open;
          double upDownPercent = entity.ratio ?? (upDown / entity.open) * 100;
          infos = [
            getDate(entity.time),
            entity.open.toStringAsFixed(widget.fixedLength),
            entity.high.toStringAsFixed(widget.fixedLength),
            entity.low.toStringAsFixed(widget.fixedLength),
            entity.close.toStringAsFixed(widget.fixedLength),
            "${upDown > 0 ? "+" : ""}${upDown.toStringAsFixed(widget.fixedLength)}",
            "${upDownPercent > 0 ? "+" : ''}${upDownPercent.toStringAsFixed(2)}%",
            entity.amount.toInt().toString()
          ];
          return Container(
            margin: EdgeInsets.only(left: snapshot.data.isLeft ? 4 : mWidth - mWidth / 3 - 4, top: 25),
            width: mWidth / 3,
            decoration: BoxDecoration(color: ChartColors.selectFillColor, border: Border.all(color: ChartColors.selectBorderColor, width: 0.5)),
            child: ListView.builder(
              padding: EdgeInsets.all(4),
              itemCount: infoNamesCN.length,
              itemExtent: 14.0,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return _buildItem(infos[index], widget.isChinese ? infoNamesCN[index] : infoNamesEN[index]);
              },
            ),
          );
        });
  }

  Widget _buildItem(String info, String infoName) {
    Color color = Colors.white;
    if (info.startsWith("+"))
      color = Colors.green;
    else if (info.startsWith("-"))
      color = Colors.red;
    else
      color = Colors.white;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: Text("$infoName", style: const TextStyle(color: Colors.white, fontSize: 10.0))),
        Text(info, style: TextStyle(color: color, fontSize: 10.0)),
      ],
    );
  }

  String getDate(int date) => dateFormat(DateTime.fromMillisecondsSinceEpoch(date), widget.timeFormat);
}
