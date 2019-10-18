# k_chart
A Flutter K Chart.And easy to use.

![vertical](https://github.com/mafanwei/k_chart/blob/master/example/images/demo.gif)
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

use k line chart:
```
Container(
              height: 450,
              width: double.infinity,
              child: KChartWidget(
                datas,//Required，Data must be an ordered list，(history=>now)
                isLine: isLine,//Decide whether it is k-line or time-sharing
                mainState: _mainState,//Decide what the main view shows
                secondaryState: _secondaryState,//Decide what the sub view shows
                fixedLength: 2,//Displayed decimal precision
                timeFormat: TimeFormat.YEAR_MONTH_DAY,
                onLoadMore: () {},//Called when the list is swiped to the far left,use it load history.
                maDayList: [5,10,20],//Display of ma
                bgColor: [Colors.black],//The background color of the chart is gradient
                isChinese: true,//Graphic language
                isOnDrag: (isDrag){},// true is on Drag.Don't load data while Draging.
              ),
            ),
```

use depth chart:
```
DepthChart(_bids, _asks) //Note: Datas must be an ordered list，
```
#### Donate

Buy the writer a cup of coffee.

![alipay](https://img-blog.csdnimg.cn/20181205161540134.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3F3ZTI1ODc4,size_16,color_FFFFFF,t_70)

![wechat](https://img-blog.csdnimg.cn/20181205162201519.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3F3ZTI1ODc4,size_16,color_FFFFFF,t_70)
