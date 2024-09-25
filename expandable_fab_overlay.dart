import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AnchoredOverlay extends StatelessWidget {
  final bool showOverlay;
  final Widget Function(BuildContext, Offset anchor, Function toggleOverlay) overlayBuilder;
  final Widget child;

  const AnchoredOverlay({
    Key? key,
    required this.showOverlay,
    required this.overlayBuilder,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return OverlayBuilder(
          showOverlay: showOverlay,
          overlayBuilder: (BuildContext overlayContext, Function toggleOverlay) {
            RenderBox box = context.findRenderObject() as RenderBox;
            final center = box.size.center(box.localToGlobal(const Offset(0.0, 0.0)));
            return overlayBuilder(overlayContext, center, toggleOverlay);
          },
          child: child,
        );
      },
    );
  }
}

class OverlayBuilder extends StatefulWidget {
  final bool showOverlay;
  final Widget Function(BuildContext, Function toggleOverlay) overlayBuilder;
  final Widget child;

  OverlayBuilder({
    Key? key,
    required this.showOverlay,
    required this.overlayBuilder,
    required this.child,
  }) : super(key: key);

  @override
  _OverlayBuilderState createState() => _OverlayBuilderState();
}

class _OverlayBuilderState extends State<OverlayBuilder> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.showOverlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _showOverlay());
    }
  }

  @override
  void didUpdateWidget(OverlayBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncWidgetAndOverlay());
  }

  @override
  void dispose() {
    if (_isShowingOverlay()) {
      _hideOverlay();
    }
    super.dispose();
  }

  bool _isShowingOverlay() => _overlayEntry != null;

  void _showOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (context) =>
          widget.overlayBuilder(
            context,
            (bool isVisibleOrNot) => _toggleOverlay(isVisibleOrNot),
        ),
      );
      Overlay.of(context)!.insert(_overlayEntry!);
    }
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _toggleOverlay(bool visible){
    if(visible)
      _showOverlay();
    else
      _hideOverlay();
  }

  void _syncWidgetAndOverlay() {
    if (_isShowingOverlay() && !widget.showOverlay) {
      _hideOverlay();
    } else if (!_isShowingOverlay() && widget.showOverlay) {
      _showOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class CenterAbout extends StatelessWidget {
  final Offset position;
  final Widget child;

  const CenterAbout({
    Key? key,
    required this.position,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position.dy - 28.h,
      left: position.dx - 28.w,
      child: child,
      /*
      //child: FractionalTranslation(
        //translation: const Offset(-0.5, -0.5),
        //child: child,
      //),
      */
    );
  }
}

