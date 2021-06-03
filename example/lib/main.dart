import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:k_chart/chart_style.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:k_chart/k_chart_widget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<KLineEntity> datas;
  bool showLoading = true;
  MainState _mainState = MainState.MA;
  bool _volHidden = false;
  SecondaryState _secondaryState = SecondaryState.MACD;
  bool isLine = true;
  bool isChinese = true;
  List<DepthEntity> _bids, _asks;

  ChartStyle chartStyle = new ChartStyle();
  ChartColors chartColors = new ChartColors();

  @override
  void initState() {
    super.initState();
    getData('1day');
    rootBundle.loadString('assets/depth.json').then((result) {
      final parseJson = json.decode(result);
      Map tick = parseJson['tick'];
      var bids = tick['bids']
          .map((item) => DepthEntity(item[0], item[1]))
          .toList()
          .cast<DepthEntity>();
      var asks = tick['asks']
          .map((item) => DepthEntity(item[0], item[1]))
          .toList()
          .cast<DepthEntity>();
      initDepth(bids, asks);
    });
  }

  void initDepth(List<DepthEntity> bids, List<DepthEntity> asks) {
    if (bids == null || asks == null || bids.isEmpty || asks.isEmpty) return;
    _bids = [];
    _asks = [];
    double amount = 0.0;
    bids?.sort((left, right) => left.price.compareTo(right.price));
    //累加买入委托量
    bids.reversed.forEach((item) {
      amount += item.vol;
      item.vol = amount;
      _bids.insert(0, item);
    });

    amount = 0.0;
    asks?.sort((left, right) => left.price.compareTo(right.price));
    //累加卖出委托量
    asks?.forEach((item) {
      amount += item.vol;
      item.vol = amount;
      _asks.add(item);
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: KChartWidget(
    //       [
    //         KLineEntity.fromCustom(
    //           amount: 10,
    //           open: 10,
    //           close: 10,
    //           change: 10,
    //           ratio: 10,
    //           time: 10,
    //           high: 10,
    //           low: 10,
    //           vol: 10,
    //         ),
    //       ],
    //       ChartStyle(), // Required for styling purposes
    //       ChartColors(), // Required for styling purposes
    //
    //       isLine: false,
    //       // Decide whether it is k-line or time-sharing
    //       mainState: MainState.BOLL,
    //       // Decide what the main view shows
    //       secondaryState: SecondaryState.CCI,
    //       // Decide what the sub view shows
    //       fixedLength: 2,
    //       // Displayed decimal precision
    //       timeFormat: TimeFormat.YEAR_MONTH_DAY,
    //       onLoadMore: (bool a) {},
    //       // Called when the data scrolls to the end. When a is true, it means the user is pulled to the end of the right side of the data. When a
    //       // is false, it means the user is pulled to the end of the left side of the data.
    //       maDayList: [5, 10, 20],
    //       // Display of MA,This parameter must be equal to DataUtil.calculate‘s maDayList
    //       bgColor: [Colors.black, Colors.black],
    //       // The background color of the chart is gradient
    //       isChinese: false,
    //       // Graphic language
    //       // volHidden: false,
    //       // hide volume
    //       isOnDrag: (isDrag) {},
    //       // true is on Drag.Don't load data while Draging.
    //       onSecondaryTap: () {} // on secondary rect taped.
    //   ),
    // );
    return Scaffold(
      backgroundColor: Color(0xff17212F),
//      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        children: <Widget>[
          Stack(children: <Widget>[
            Container(
              height: 450,
              width: double.infinity,
              child: KChartWidget(
                datas,
                chartStyle,
                chartColors,
                isLine: isLine,
                mainState: _mainState,
                volHidden: _volHidden,
                secondaryState: _secondaryState,
                fixedLength: 2,
                timeFormat: TimeFormat.YEAR_MONTH_DAY,
                isChinese: isChinese,
              ),
            ),
            if (showLoading)
              Container(
                  width: double.infinity,
                  height: 450,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator()),
          ]),
          buildButtons(),
          Container(
            height: 230,
            width: double.infinity,
            child: DepthChart(_bids, _asks, this.chartColors),
          )
        ],
      ),
    );
  }

  Widget buildButtons() {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: <Widget>[
        button("分时", onPressed: () => isLine = true),
        button("k线", onPressed: () => isLine = false),
        button("MA", onPressed: () => _mainState = MainState.MA),
        button("BOLL", onPressed: () => _mainState = MainState.BOLL),
        button("隐藏", onPressed: () => _mainState = MainState.NONE),
        button("MACD", onPressed: () => _secondaryState = SecondaryState.MACD),
        button("KDJ", onPressed: () => _secondaryState = SecondaryState.KDJ),
        button("RSI", onPressed: () => _secondaryState = SecondaryState.RSI),
        button("WR", onPressed: () => _secondaryState = SecondaryState.WR),
        button("CCI", onPressed: () => _secondaryState = SecondaryState.CCI),
        button("隐藏副视图", onPressed: () => _secondaryState = SecondaryState.NONE),
        button(_volHidden ? "显示成交量" : "隐藏成交量",
            onPressed: () => _volHidden = !_volHidden),
        button("切换中英文", onPressed: () => isChinese = !isChinese),
        button("Customize UI", onPressed: () {
          setState(() {
            chartColors.selectBorderColor = Colors.red;
            chartColors.selectFillColor = Colors.red;
            chartColors.lineFillColor = Colors.red;
            chartColors.kLineColor = Colors.yellow;
          });
        }),
      ],
    );
  }

  Widget button(String text, {VoidCallback onPressed}) {
    return TextButton(
      onPressed: () {
        if (onPressed != null) {
          onPressed();
          setState(() {});
        }
      },
      child: Text("$text"),
      style: TextButton.styleFrom(
        primary: Colors.white,
        minimumSize: Size(88, 44),
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(2.0)),
        ),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void getData(String period) {
    Future<String> future = getIPAddress('$period');
    future.then((result) {
      Map parseJson = json.decode(result);
      List list = parseJson['data'];
      datas = list
          .map((item) => KLineEntity.fromJson(item))
          .toList()
          .reversed
          .toList()
          .cast<KLineEntity>();
      DataUtil.calculate(datas);
      showLoading = false;
      setState(() {});
    }).catchError((_) {
      showLoading = false;
      setState(() {});
      print('### datas error $_');
    });
  }

  //获取火币数据，需要翻墙
  Future<String> getIPAddress(String period) async {
    var url =
        'https://api.huobi.br.com/market/history/kline?period=${period ?? '1day'}&size=300&symbol=btcusdt';
    String result;
    var response = await http.get(url);
    if (response.statusCode == 200) {
      result = response.body;
    } else {
      print('Failed getting IP address');
    }
    return result;
  }
}
