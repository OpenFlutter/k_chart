import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:k_chart/k_chart_widget.dart';
import 'package:http/http.dart' as http;

class BogachChartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bogach Chart',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: BogachChart(),
    );
  }
}

class BogachChart extends StatefulWidget {
  BogachChart({Key key}) : super(key: key);

  @override
  _BogachChartState createState() => _BogachChartState();
}

class _BogachChartState extends State<BogachChart> {
  List<KLineEntity> datas;
  bool showLoading = true;
  bool _volHidden = true;
  bool isLine = true;

  @override
  void initState() {
    super.initState();
    getData('1day');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff17212F),
      appBar: AppBar(title: Text('Bogach Chart')),
      body: ListView(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Container(
                height: 450,
                width: double.infinity,
                child: _buildChart(),
              ),
              if (showLoading)
                Container(
                  width: double.infinity,
                  height: 450,
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          buildButtons(),
        ],
      ),
    );
  }

  KChartWidget _buildChart() {
    return KChartWidget(
      datas,
      bgColor: [Colors.white, Colors.white],
      isLine: isLine,
      mainState: MainState.NONE,
      volHidden: _volHidden,
      secondaryState: SecondaryState.NONE,
      fixedLength: 2,
      dateFormat: ['MM'],
      language: KChartLanguage.russian,
      selectionLineColor: Colors.black54,
      lineChartColor: Colors.black87,
      lineChartFillColor: Colors.black38,
      maxMinColor: Colors.black87,
      chartVerticalPadding: 24,
    );
  }

  Widget buildButtons() {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: <Widget>[
        button("Line", onPressed: () => isLine = true),
        button("Candles", onPressed: () => isLine = false),
        button(
          _volHidden ? "Show volume" : "Hide volume",
          onPressed: () => _volHidden = !_volHidden,
        ),
      ],
    );
  }

  Widget button(String text, {VoidCallback onPressed}) {
    return FlatButton(
      onPressed: () {
        onPressed?.call();
        setState(() {});
      },
      child: Text(text),
      color: Colors.blue,
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
    }).catchError((error) {
      showLoading = false;
      setState(() {});
      print('ERROR: $error');
    });
  }

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
