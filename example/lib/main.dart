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
  MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<KLineEntity>? datas;
  bool showLoading = true;
  MainState _mainState = MainState.BOLL;
  bool _volHidden = true;
  SecondaryState _secondaryState = SecondaryState.NONE;
  bool isLine = false;
  List<DepthEntity>? _bids, _asks;

  @override
  void initState() {
    super.initState();
    getData('1day');
    rootBundle.loadString('assets/depth.json').then((result) {
      final parseJson = json.decode(result);
      final tick = parseJson['tick'] as Map<String, dynamic>;
      final List<DepthEntity> bids = (tick['bids'] as List<dynamic>)
          .map<DepthEntity>(
              (item) => DepthEntity(item[0] as double, item[1] as double))
          .toList();
      final List<DepthEntity> asks = (tick['asks'] as List<dynamic>)
          .map((item) => DepthEntity(item[0] as double, item[1] as double))
          .toList()
          .cast<DepthEntity>();
      // initDepth(bids, asks);
    });
  }

  // void initDepth(List<DepthEntity>? bids, List<DepthEntity>? asks) {
  //   if (bids == null || asks == null || bids.isEmpty || asks.isEmpty) return;
  //   _bids = [];
  //   _asks = [];
  //   double amount = 0.0;
  //   bids.sort((left, right) => left.price.compareTo(right.price));
  //   for (final item in bids.reversed) {
  //     amount += item.amount;
  //     item.amount = amount;
  //     _bids!.insert(0, item);
  //   }
  //
  //   amount = 0.0;
  //   asks.sort((left, right) => left.price.compareTo(right.price));
  //   for (final item in asks) {
  //     amount += item.amount;
  //     item.amount = amount;
  //     _asks!.add(item);
  //   }
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      children: <Widget>[
        buildTime(),
        Stack(children: <Widget>[
          Container(
            height: 450,
            width: double.infinity,
            child: KChartWidget(
                datas, // Required，Data must be an ordered list，(history=>now)
                ChartStyle(), // Required for styling purposes
                ChartColors(), // Required for styling purposes

                isLine: isLine,
                // Decide whether it is k-line or time-sharing
                mainState: _mainState,
                // Decide what the main view shows
                secondaryState: _secondaryState,
                // Decide what the sub view shows
                fixedLength: 2,
                // Displayed decimal precision
                timeFormat: TimeFormat.YEAR_MONTH_DAY,
                onLoadMore: (bool a) {},
                // Called when the data scrolls to the end. When a is true, it means the user is pulled to the end of the right side of the data. When a
                // is false, it means the user is pulled to the end of the left side of the data.
                maDayList: [5, 10, 20],
                // Display of MA,This parameter must be equal to DataUtil.calculate‘s maDayList
                bgColor: [Colors.black, Colors.black],
                // The background color of the chart is gradient
                isChinese: false,
                // Graphic language
                volHidden: _volHidden,
                // hide volume
                isOnDrag: (isDrag) {},
                // true is on Drag.Don't load data while Draging.
                onSecondaryTap: () {} // on secondary rect taped.
                ),
          ),
          if (showLoading)
            Container(
                width: double.infinity,
                height: 450,
                alignment: Alignment.center,
                child: const CircularProgressIndicator()),
        ]),
        buildButtons(),
        // if (_bids != null && _asks != null)
        //   Container(
        //     height: 230,
        //     width: double.infinity,
        //     child: DepthChart(_bids!, _asks!),
        //   )
      ],
    );
  }

  Widget buildButtons() {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          button('MA',
              onPressed: () => _mainState = (_mainState == MainState.NONE)
                  ? MainState.MA
                  : MainState.NONE),
          button('BOLL',
              onPressed: () => _mainState = (_mainState == MainState.NONE)
                  ? MainState.BOLL
                  : MainState.NONE),
          button('VOL', onPressed: () => _volHidden = !_volHidden),
          button('MACD',
              onPressed: () => _secondaryState =
                  (_secondaryState == SecondaryState.NONE)
                      ? SecondaryState.MACD
                      : SecondaryState.NONE),
          button('KDJ',
              onPressed: () => _secondaryState =
                  (_secondaryState == SecondaryState.NONE)
                      ? SecondaryState.KDJ
                      : SecondaryState.NONE),
          button('RSI',
              onPressed: () => _secondaryState =
                  (_secondaryState == SecondaryState.NONE)
                      ? SecondaryState.RSI
                      : SecondaryState.NONE),
          button('WR',
              onPressed: () => _secondaryState =
                  (_secondaryState == SecondaryState.NONE)
                      ? SecondaryState.WR
                      : SecondaryState.NONE),
        ],
      ),
    );
  }

  Widget buildTime() {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          button('Line', onPressed: () => isLine = !isLine),
          // button('update', onPressed: () {
          //   //Cập nhật phần dữ liệu cuối cùng
          //   datas!.last.close =
          //       datas!.last.close + (Random().nextInt(100) - 50).toDouble();
          //   datas!.last.high = max(datas!.last.high, datas!.last.close);
          //   datas!.last.low = min(datas!.last.low, datas!.last.close);
          //   DataUtil.updateLastData(datas);
          // }),
          // button('addData', onPressed: () {
          //   // Sao chép một đối tượng, sửa đổi dữ liệu
          //   final kLineEntity = KLineEntity.fromJson(datas!.last.toJson());
          //   kLineEntity.id = kLineEntity.id! + 60 * 60 * 24;
          //   kLineEntity.open = kLineEntity.close;
          //   kLineEntity.close =
          //       kLineEntity.close + (Random().nextInt(100) - 50).toDouble();
          //   datas!.last.high = max(datas!.last.high, datas!.last.close);
          //   datas!.last.low = min(datas!.last.low, datas!.last.close);
          //   DataUtil.addLastData(datas, kLineEntity);
          // }),
          button('1month', onPressed: () async {
//              showLoading = true;
//              setState(() {});
            //getData('1mon');
            final String result =
                await rootBundle.loadString('assets/kmon.json');
            final parseJson = json.decode(result) as Map<String, dynamic>;
            final list = parseJson['data'] as List<dynamic>;
            datas = list
                .map((item) =>
                    KLineEntity.fromJson(item as Map<String, dynamic>))
                .toList()
                .reversed
                .toList()
                .cast<KLineEntity>();
            DataUtil.calculate(datas!);
          }),
          button('1Day', onPressed: () {
            showLoading = true;
            getData('1day');
          }),
        ],
      ),
    );
  }

  Widget button(String text, {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: () {
        if (onPressed != null) {
          onPressed();
          setState(() {});
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Text(
          text,
          style: TextStyle(fontSize: 11),
        ),
      ),
    );
  }

  void getData(String period) async {
    late String result;
    try {
      result = await getIPAddress(period);
    } catch (e) {
      print('Không lấy được dữ liệu, lấy dữ liệu cục bộ');
      result = await rootBundle.loadString('assets/kline.json');
    } finally {
      final parseJson = json.decode(result) as Map<String, dynamic>;
      final list = parseJson['data'] as List<dynamic>;
      datas = list
          .map((item) => KLineEntity.fromJson(item as Map<String, dynamic>))
          .toList()
          .reversed
          .toList()
          .cast<KLineEntity>();
      DataUtil.calculate(datas!);
      showLoading = false;
      setState(() {});
    }
  }

  Future<String> getIPAddress(String? period) async {
    //Huobi api, cần khắc phục bức tường
    final url =
        'https://api.huobi.br.com/market/history/kline?period=${period ?? '1day'}&size=300&symbol=btcusdt';
    String result;
    final response =
        await http.get(Uri.parse(url)).timeout(const Duration(seconds: 7));
    if (response.statusCode == 200) {
      result = response.body;
    } else {
      return Future.error('Nhận thất bại');
    }
    return result;
  }
}
