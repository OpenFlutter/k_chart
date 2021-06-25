class ChartTranslations {
  final String date;
  final String open;
  final String high;
  final String low;
  final String close;
  final String changeAmount;
  final String change;
  final String amount;

  const ChartTranslations({
    this.date = 'Date',
    this.open = 'Open',
    this.high = 'High',
    this.low = 'Low',
    this.close = 'Close',
    this.changeAmount = 'Change',
    this.change = 'Change%',
    this.amount = 'Amount',
  });

  String byIndex(int index) {
    switch (index) {
      case 0:
        return date;
      case 1:
        return open;
      case 2:
        return high;
      case 3:
        return low;
      case 4:
        return close;
      case 5:
        return changeAmount;
      case 6:
        return change;
      case 7:
        return amount;
    }

    throw UnimplementedError();
  }
}

const kChartTranslations = {
  'zh_CN': ChartTranslations(
    date: '时间',
    open: '开',
    high: '高',
    low: '低',
    close: '收',
    changeAmount: '涨跌额',
    change: '涨跌幅',
    amount: '成交额',
  ),
};
