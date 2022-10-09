## [0.1.1]

* NEW: Initial Release.

## [0.1.2]

* NEW: Add Hidden Volume

## [0.1.3]

* NEW: Add CCI
 
## [0.1.4]

* NEW: Add onSecondaryTap
* Changed the k-line drawing logic

## [0.2.0]

* NEW: Added real-time price display
* Breaking Change: Ability to customise UI of KChartWidget.(The chartStyle and chartColors must be specified)

## [0.2.1]

* Fix: Fixed some UI issues about zooming

## [0.3.0]

* Breaking Change: null safety.
* NEW: Add line under Touch Dialog.

## [0.3.1]

* NEW: More color can change.

## [0.3.2]

* NEW: You can show or hide the grid.
* Changed the multi-language implementation.(Please migrate to the new way as soon as possible)
* Changed the period of kdj from 14 to 9.

## [0.4.0]

* Changed the way the marker values are displayed, from right to left.
* Changed the UI when gridlines are hidden.
* Upgraded the display of real-time prices.
* More configurations are available.

## [0.4.1]

* Fix a bug about NPE.

## [0.5.0]

* Fixed Vertical text alignment and make amount nullable.
* Fixed nowPrice text painting position.
* Add click show detailed data.
* View display area boundary value drawing. 
* Always show the now price.

## [0.6.0]

* Delete `bgColor` api.('Use `chartColors.bgColor` instead.')
* Add TradeLine.
* Fixed about data not contain `change` or `radio`.

## [0.6.1]

* Add `chartColors.lineFillInsideColor`.
* Add `materialInfoDialog` config.
* Fix: removes duplicate crossLine and crossLine text rendering.

## [0.7.0]

* Add `xFrontPadding`. (padding in front. default 100)
* Fix: KChart and DepthChart onPress selection when they don't fill the whole screen.