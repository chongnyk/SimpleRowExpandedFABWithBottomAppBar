import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExpandableFabHelper Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

/// A simple HomePage that uses the expandableFabHelper to show a FAB.
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ExpandableFabHelper Demo')),
      body: const Center(child: Text('Home Page')),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: expandableFabHelper.buildExpandableFabNav(
        context,
        true, // overlayVisible
        true, // longPressAvail
        const DummyPage(title: 'Next Page'),
        const [DummyPage(title: 'Option 1'), DummyPage(title: 'Option 2')],
        ImageIcon(
          const AssetImage('assets/icon.png'),
          size: 24,
        ) as Image,
        [
          ImageIcon(
            const AssetImage('assets/option1.png'),
            size: 24,
          ) as Image,
          ImageIcon(
            const AssetImage('assets/option2.png'),
            size: 24,
          ) as Image,
        ],
      ),
    );
  }
}

/// A dummy page used for navigation.
class DummyPage extends StatelessWidget {
  final String title;
  const DummyPage({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}

/// A simplified version of the ExpandableFab widget with a navPush constructor.
class ExpandableFab extends StatefulWidget {
  final Function pressAction;
  final bool longPressAction;
  final Widget pressOption;
  final List<Widget>? longPressOptions;
  final Image pressImage;
  final List<Image>? longPressImages;

  const ExpandableFab({
    Key? key,
    required this.pressAction,
    required this.longPressAction,
    required this.pressOption,
    this.longPressOptions,
    required this.pressImage,
    this.longPressImages,
  }) : super(key: key);

  ExpandableFab.navPush({
    Key? key,
    required bool longPressAction,
    required Widget pressOption,
    List<Widget>? longPressOptions,
    required Image pressImage,
    List<Image>? longPressImages,
  }) : this(
          key: key,
          pressAction: (context, pressOption) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => pressOption),
            );
          },
          longPressAction: longPressAction,
          pressOption: pressOption,
          longPressOptions: longPressOptions,
          pressImage: pressImage,
          longPressImages: longPressImages,
        );

  @override
  State createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  bool _open = false;
  bool _expandable = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    if (widget.longPressAction &&
        widget.longPressOptions != null &&
        widget.longPressOptions!.isNotEmpty) {
      _expandable = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _onExpandedPress(int index) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => widget.longPressOptions![index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return (_expandable)
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 172.w,
                height: 60.h,
                child: ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _controller,
                    curve: const Interval(
                      0.0,
                      0.75,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: Container(
                    width: 172.w,
                    height: 60.h,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEFEFE),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(widget.longPressImages!.length, (int index) {
                        return _buildChild(index);
                      }),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 13.h),
              _buildFab(),
            ],
          )
        : _buildFab();
  }

  Widget _buildChild(int index) {
    return Container(
      height: 70,
      width: 56,
      alignment: Alignment.topCenter,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.0,
            1.0 -
                (widget.longPressImages!.length - index) /
                    widget.longPressImages!.length /
                    2.0,
            curve: Curves.easeOut,
          ),
        ),
        child: RawMaterialButton(
          fillColor: const Color(0xFFFEFEFE),
          elevation: 0,
          shape: const CircleBorder(),
          constraints: BoxConstraints.tightFor(
            width: 44.w,
            height: 44.h,
          ),
          onPressed: () {
            _onExpandedPress(index);
            _toggleExpanded();
          },
          child: widget.longPressImages![index],
        ),
      ),
    );
  }

  Widget _buildFab() {
    return RawMaterialButton(
      onPressed: () {
        if (_expandable && _open) {
          _toggleExpanded();
        } else {
          widget.pressAction(context, widget.pressOption);
        }
      },
      onLongPress: () {
        if (_expandable) _toggleExpanded();
      },
      fillColor: const Color(0xFFFEFEFE),
      shape: const CircleBorder(),
      elevation: 6.0,
      constraints: BoxConstraints.tightFor(
        width: 56.w,
        height: 56.h,
      ),
      child: (_expandable && !_open || !_expandable)
          ? widget.pressImage
          : const Icon(Icons.close),
    );
  }
}

/// Helper class that creates overlay-based buttons.
class expandableFabHelper {
  static Widget buildExpandableFabNav(
    BuildContext context,
    bool overlayVisible,
    bool longPressAvail,
    Widget nextPage,
    List<Widget>? pagesAvail,
    Image currentPageIcon,
    List<Image>? pagesAvailImages,
  ) {
    return AnchoredOverlay(
      showOverlay: overlayVisible,
      overlayBuilder: (context, offset, toggleOverlay) {
        return CenterAbout(
          position: Offset(offset.dx - 58.w, offset.dy - 71.h),
          child: ExpandableFab.navPush(
            longPressAction: longPressAvail,
            pressOption: nextPage,
            longPressOptions: pagesAvail,
            pressImage: currentPageIcon,
            longPressImages: pagesAvailImages,
          ),
        );
      },
      child: Container(
        width: 56.w,
        height: 56.h,
      ),
    );
  }

  static Widget buildExpandableFabModal(
    BuildContext context,
    Widget modalBottomSheetContents,
    Image showBottomSheetButton,
  ) {
    return AnchoredOverlay(
      showOverlay: true,
      overlayBuilder: (context, offset, toggleOverlay) {
        return CenterAbout(
          position: Offset(offset.dx, offset.dy),
          child: ExpandableFab.navPush(
            longPressAction: false,
            pressOption: modalBottomSheetContents,
            longPressOptions: null,
            pressImage: showBottomSheetButton,
            longPressImages: null,
          ),
        );
      },
      child: Container(
        width: 56.w,
        height: 56.h,
      ),
    );
  }
}

/// A simple implementation of an overlay that positions a widget relative to its child.
typedef OverlayBuilder = Widget Function(
    BuildContext context, Offset offset, void Function(bool) toggleOverlay);

class AnchoredOverlay extends StatefulWidget {
  final Widget child;
  final bool showOverlay;
  final OverlayBuilder overlayBuilder;

  const AnchoredOverlay({
    Key? key,
    required this.child,
    required this.showOverlay,
    required this.overlayBuilder,
  }) : super(key: key);

  @override
  _AnchoredOverlayState createState() => _AnchoredOverlayState();
}

class _AnchoredOverlayState extends State<AnchoredOverlay> {
  final GlobalKey _key = GlobalKey();
  Offset _offset = Offset.zero;

  void _updateOffset() {
    final RenderBox? renderBox =
        _key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      setState(() {
        _offset = position;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateOffset());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(key: _key, child: widget.child),
        if (widget.showOverlay)
          widget.overlayBuilder(context, _offset, (visible) {}),
      ],
    );
  }
}

/// A widget that positions its child at a given offset.
class CenterAbout extends StatelessWidget {
  final Offset position;
  final Widget child;

  const CenterAbout({Key? key, required this.position, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: child,
    );
  }
}
