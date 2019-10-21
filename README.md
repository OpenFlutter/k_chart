# k_chart
A Flutter K Chart.And easy to use.

![demo](https://github.com/mafanwei/k_chart/blob/master/example/images/demo.gif)
## Getting Started
#### Install
```
dependencies:
  k_chart: ^0.1.1
```
or use latest：
```
k_chart:
    git:
      url: https://github.com/mafanwei/k_chart
```
#### Usage

**When you change the data, you must call this:**
```dart
DataUtil.calculate(datas); //This function has some optional parameters: n is BOLL N-day closing price. k is BOLL param.
```

use k line chart:
```dart
Container(
              height: 450,
              width: double.infinity,
              child: KChartWidget(
                datas,// Required，Data must be an ordered list，(history=>now)
                isLine: isLine,// Decide whether it is k-line or time-sharing
                mainState: _mainState,// Decide what the main view shows
                secondaryState: _secondaryState,// Decide what the sub view shows
                fixedLength: 2,// Displayed decimal precision
                timeFormat: TimeFormat.YEAR_MONTH_DAY,
                onLoadMore: () {},// Called when the list is swiped to the far left,use it load history.
                maDayList: [5,10,20],// Display of MA,This parameter must be equal to DataUtil.calculate‘s maDayList
                bgColor: [Colors.black, Colors.black],// The background color of the chart is gradient
                isChinese: true,// Graphic language
                isOnDrag: (isDrag){},// true is on Drag.Don't load data while Draging.
              ),
            ),
```

use depth chart:
```dart
DepthChart(_bids, _asks) //Note: Datas must be an ordered list，
```
#### Donate

Buy a cup of coffee for the author.

<img src="https://img-blog.csdnimg.cn/20181205161540134.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3F3ZTI1ODc4,size_16,color_FFFFFF,t_70" width="375" alt="alipay"/>
<img src="https://img-blog.csdnimg.cn/20181205162201519.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3F3ZTI1ODc4,size_16,color_FFFFFF,t_70" width="375" alt="wechat"/>
