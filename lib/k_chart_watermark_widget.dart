import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:k_chart/flutter_k_chart.dart';

class KChartWatermarkWidget extends SingleChildRenderObjectWidget {
  final BaseChartPainter chartPainter;

  KChartWatermarkWidget({
    Key? key,
    required this.chartPainter,
    Widget? child,
  }) : super(key: key, child: child);

  @override
  _WatermarkRenderBox createRenderObject(BuildContext context) {
    return _WatermarkRenderBox(chartPainter: chartPainter);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant _WatermarkRenderBox renderObject) {
    super.updateRenderObject(context, renderObject);

    renderObject..chartPainter = chartPainter;
  }
}

class _WatermarkRenderBox extends RenderProxyBox {
  BaseChartPainter chartPainter;

  _WatermarkRenderBox({
    required this.chartPainter,
  });

  @override
  void performLayout() {
    size = constraints.biggest;

    final child = this.child;
    if (child != null) {
      // Calculation process is similar to [BaseChartPainter.initRect].
      // Updated [BaseChartPainter.initRect] should also update following.
      final displayHeight =
          size.height - chartPainter.mTopPadding - chartPainter.mBottomPadding;
      final volHeight =
          chartPainter.volHidden != true ? displayHeight * 0.2 : 0;
      final secondaryHeight = chartPainter.secondaryState != SecondaryState.NONE
          ? displayHeight * 0.2
          : 0;
      final mainHeight = displayHeight - volHeight - secondaryHeight;
      final childConstraints = constraints.tighten(
        height: mainHeight + chartPainter.mTopPadding,
      );

      child.layout(childConstraints);
    }
  }
}
