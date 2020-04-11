import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class FocusListView extends StatefulWidget {
  Axis scrollDirection;
  bool reverse;
  ScrollPhysics physics;
  EdgeInsetsGeometry padding;
  bool primary;
  int itemCount;
  FocusScrollController controller;
  bool shrinkWrap;
  double focusSize;
  double unFocusSize;
  List<Widget> backgroundChildren;
  List<Widget> children;
  IndexedWidgetBuilder itemBuilder;
  IndexedWidgetBuilder backgroundItemBuilder;

  double maxBlur;
  Color overlayerColor;
  double overlayerMaxOpacity;

  Color backgroundColor;

  bool focusOnTap;
  Function(bool isFocus) onTap;
  Function(int index) onIndexChanged;

  EdgeInsetsGeometry itemPadding;
  BorderRadius borderRadius;

  FocusListView(
      {Key key,
        this.scrollDirection: Axis.vertical,
        this.reverse: false,
        this.physics: const AlwaysScrollableScrollPhysics(),
        this.padding: const EdgeInsets.all(0),
        this.primary,
        this.focusSize: 200,
        this.unFocusSize: 50,
        this.controller,
        this.shrinkWrap: false,
        this.backgroundChildren,
        this.children,
        this.maxBlur: 0.0,
        this.overlayerColor: Colors.black,
        this.overlayerMaxOpacity: 0.7,
        this.backgroundColor: Colors.transparent,
        this.focusOnTap: false,
        this.onTap,
        this.onIndexChanged,
        this.itemPadding: const EdgeInsets.all(0),
        this.borderRadius: const BorderRadius.only()})
      : assert(children != null),
        super(key: key);

  FocusListView.builder(
      {Key key,
        this.scrollDirection: Axis.vertical,
        this.reverse: false,
        this.physics: const AlwaysScrollableScrollPhysics(),
        this.padding: const EdgeInsets.all(0),
        this.primary,
        this.itemCount,
        this.focusSize: 200,
        this.unFocusSize: 50,
        this.controller,
        this.shrinkWrap: false,
        this.itemBuilder,
        this.backgroundItemBuilder,
        this.maxBlur: 0.0,
        this.overlayerColor: Colors.black,
        this.overlayerMaxOpacity: 0.7,
        this.backgroundColor: Colors.transparent,
        this.focusOnTap: false,
        this.onTap,
        this.onIndexChanged,
        this.itemPadding: const EdgeInsets.all(0),
        this.borderRadius: const BorderRadius.only()})
      : assert(itemBuilder != null),
        super(key: key);

  @override
  FocusListViewState createState() => new FocusListViewState();
}

class FocusListViewState extends State<FocusListView> {
  GlobalKey heightKey = GlobalKey();
  double widgetSize;
  int focusIndex = 0;
  double nextFocusSize;
  FocusScrollController controller;

  @override
  Widget build(BuildContext context) {
    if (widgetSize == null) {
      RenderBox box = heightKey.currentContext?.findRenderObject();
      if (box != null) {
        setState(() {
          widgetSize = widget.scrollDirection == Axis.vertical
              ? box.size.height
              : box.size.width;
        });
      }
    }

    return Container(
      color: widget.backgroundColor,
      key: heightKey,
      child: Listener(
        onPointerUp: (e) {
          if (controller.offset >
              ((widget.itemCount ?? widget.children.length) - 1) *
                  widget.focusSize) {
            controller.animateTo(
                ((widget.itemCount ?? widget.children.length) - 1) *
                    widget.focusSize,
                duration: Duration(milliseconds: 350),
                curve: Curves.easeInOut);
          }
        },
        child: ListView.builder(
          scrollDirection: widget.scrollDirection,
          reverse: widget.reverse,
          padding: widget.padding,
          itemCount: (widget.itemCount ?? widget.children.length) + 1,
          controller: widget.controller ?? controller,
          physics: PageEnableScrollPhysics(
              pageSize: widget.focusSize, parent: widget.physics),
          shrinkWrap: widget.shrinkWrap,
          itemBuilder: (BuildContext context, int index) {
            if (index == (widget.itemCount ?? widget.children.length)) {
              return Container(
                  height: max(
                      widgetSize - widget.focusSize + widget.unFocusSize, 10),
                  width: max(
                      widgetSize - widget.focusSize + widget.unFocusSize, 10));
            }
            double size = index <= focusIndex
                ? widget.focusSize
                : (index == focusIndex + 1
                ? nextFocusSize
                : widget.unFocusSize);
            return GestureDetector(
              onTap: () {
                if (widget.focusOnTap) {
                  controller.animateTo(widget.focusSize * index,
                      duration: Duration(milliseconds: 350),
                      curve: Curves.easeInOut);
                }
                if (widget.onTap != null) {
                  widget.onTap(focusIndex == index);
                }
              },
              child: Container(
                padding: widget.itemPadding,
                height: widget.scrollDirection == Axis.vertical ? size : null,
                width: widget.scrollDirection == Axis.horizontal ? size : null,
                alignment: widget.scrollDirection == Axis.vertical
                    ? Alignment.bottomCenter
                    : Alignment.centerRight,
                child: ClipRRect(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: widget.borderRadius,
                  child: Stack(
                    fit: StackFit.expand,
                    children: widget.backgroundChildren != null
                        ? <Widget>[
                      widget.backgroundChildren[index],
                      _buildBlurAndChild(size, index),
                    ]
                        : (widget.backgroundItemBuilder != null
                        ? <Widget>[
                      widget.backgroundItemBuilder(context, index),
                      _buildBlurAndChild(size, index),
                    ]
                        : <Widget>[
                      _buildBlurAndChild(size, index),
                    ]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBlurAndChild(double size, int index) {
    if (widget.maxBlur > 0) {
      return BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: widget.maxBlur *
                (1 -
                    (size - widget.unFocusSize) /
                        (widget.focusSize - widget.unFocusSize)),
            sigmaY: widget.maxBlur *
                (1 -
                    (size - widget.unFocusSize) /
                        (widget.focusSize - widget.unFocusSize))),
        child: _buildOpacityAndChild(size, index),
      );
    } else {
      return _buildOpacityAndChild(size, index);
    }
  }

  Container _buildOpacityAndChild(double size, int index) {
    return Container(
        color: (widget.overlayerMaxOpacity > 0)
            ? Colors.black.withOpacity(widget.overlayerMaxOpacity *
            (1 -
                (size - widget.unFocusSize) /
                    (widget.focusSize - widget.unFocusSize)))
            : Colors.transparent,
        child: Center(
            child: widget.children != null
                ? widget.children[index]
                : widget.itemBuilder(context, index)));
  }

  @override
  void initState() {
    nextFocusSize = widget.unFocusSize;
    if (widget.controller == null) {
      controller = FocusScrollController();
    } else {
      controller = widget.controller;
    }
    controller.addListener(_handleScroll);
    super.initState();
  }

  _handleScroll() {
//    if (controller.targetIndex != null) {
//      int targetIndex = controller.targetIndex;
//      controller.targetIndex = null;
//      if (targetIndex <
//              (widget.itemCount ?? widget?.children?.length) &&
//          targetIndex >= 0) {
//
//        if (controller.animate == true) {
//          controller.animateTo(widget.focusSize * targetIndex,
//              duration: Duration(milliseconds: 350), curve: Curves.easeInOut);
//        } else {
//          controller.jumpTo(widget.focusSize * targetIndex);
//        }
//      }
//    } else {
    setState(() {
      _rebuildItemSize();
    });
//    }
  }

  _rebuildItemSize() {

    print(11111);

    bool indexChanged = false;
    int newFocusIndex = min(max(controller.offset ~/ widget.focusSize, 0), widget.itemCount - 1);
    print(controller.offset);
    if (newFocusIndex != focusIndex) {
      focusIndex = newFocusIndex;
      if (widget.onIndexChanged != null) {
        widget.onIndexChanged(focusIndex);
      }
    }
    nextFocusSize = max(
        controller.offset - widget.focusSize * focusIndex, widget.unFocusSize);
  }

  @override
  void dispose() {
    widget?.controller?.removeListener(_handleScroll);
    super.dispose();
  }
}

class FocusScrollController extends ScrollController {
//  int targetIndex;
//  bool animate = true;
//
//  animateToIndex(int index) {
//    targetIndex = index;
//    animate = true;
//    notifyListeners();
//  }

//  jumpToIndex(int index) {
//    targetIndex = index;
//    animate = false;
//    notifyListeners();
//  }
}

class PageEnableScrollPhysics extends ScrollPhysics {
  final double pageSize;

  const PageEnableScrollPhysics({ScrollPhysics parent, this.pageSize})
      : super(parent: parent);

  @override
  PageEnableScrollPhysics applyTo(ScrollPhysics ancestor) {
    return PageEnableScrollPhysics(
        parent: buildParent(ancestor), pageSize: this.pageSize);
  }

  double _getPage(ScrollMetrics position) {
    return position.pixels / pageSize;
  }

  double _getPixels(ScrollMetrics position, double page) {
    return page * pageSize;
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity)
      page -= 0.5;
    else if (velocity > tolerance.velocity) page += 0.5;
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((position.pixels <= position.minScrollExtent) ||
        (position.pixels >= position.maxScrollExtent))
      return super.createBallisticSimulation(position, velocity);
    final Tolerance tolerance = this.tolerance;
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels)
      return ScrollSpringSimulation(spring, position.pixels, target, velocity,
          tolerance: tolerance);
    return null;
  }

  @override
  bool get allowImplicitScrolling => false;
}
