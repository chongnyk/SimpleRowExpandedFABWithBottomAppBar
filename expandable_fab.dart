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
      title: 'Expandable FAB Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

/// The HomePage shows the ExpandableFab as the floating action button.
class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expandable FAB Demo")),
      body: const Center(child: Text("Press the FAB to navigate.")),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: ExpandableFab.navPush(
        longPressAction: true,
        pressOption: const Calendar(),
        longPressOptions: const [
          CalendarHappyDays(),
          CalendarFleets(),
          CalendarCards(),
        ],
        pressImage: ImageIcon(
          AssetImage('assets/images/iconcal_black.png'),
          size: 24,
        ),
        longPressImages: [
          ImageIcon(
            AssetImage('assets/images/cal_happy_days.png'),
            size: 24,
          ),
          ImageIcon(
            AssetImage('assets/images/cal_fleets.png'),
            size: 24,
          ),
          ImageIcon(
            AssetImage('assets/images/cal_cards.png'),
            size: 24,
          ),
        ],
      ),
    );
  }
}

/// Dummy Page: Calendar
class Calendar extends StatelessWidget {
  const Calendar({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calendar")),
      body: const Center(child: Text("Calendar Page")),
    );
  }
}

/// Dummy Page: CalendarHappyDays
class CalendarHappyDays extends StatelessWidget {
  const CalendarHappyDays({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Happy Days")),
      body: const Center(child: Text("Calendar Happy Days Page")),
    );
  }
}

/// Dummy Page: CalendarFleets
class CalendarFleets extends StatelessWidget {
  const CalendarFleets({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fleets")),
      body: const Center(child: Text("Calendar Fleets Page")),
    );
  }
}

/// Dummy Page: CalendarCards
class CalendarCards extends StatelessWidget {
  const CalendarCards({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cards")),
      body: const Center(child: Text("Calendar Cards Page")),
    );
  }
}

/// Custom ExpandableFab widget.
/// It navigates between the dummy pages using pushReplacement.
class ExpandableFab extends StatefulWidget {
  final Function pressAction;
  final bool longPressAction;
  final Widget pressOption;
  final List<Widget>? longPressOptions;
  final Image pressImage;
  final List<Image>? longPressImages;

  // List of calendar pages (not used in this standalone example)
  final List<Widget> calendarPages = const [
    Calendar(),
    CalendarHappyDays(),
    CalendarFleets(),
    CalendarCards()
  ];

  const ExpandableFab({
    Key? key,
    required this.pressAction,
    required this.longPressAction,
    required this.pressOption,
    this.longPressOptions,
    required this.pressImage,
    this.longPressImages,
  }) : assert(longPressAction || (longPressOptions == null && longPressImages == null),
             'If longPressAction is false, longPressOptions and longPressImages must also be null.'),
       assert((longPressOptions == null && longPressImages == null)
               || (longPressOptions != null && longPressImages != null && longPressOptions.length == longPressImages.length),
               'If either longPressOptions or longPressImages is not null, the other must be non-null and both must have the same length.'),
       super(key: key);

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
  State createState() => ExpandableFabState();
}

class ExpandableFabState extends State<ExpandableFab> with TickerProviderStateMixin {
  late final AnimationController _controller;
  late bool _open = false;
  late bool _expandable = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    if (widget.longPressAction && widget.longPressOptions != null && widget.longPressOptions!.isNotEmpty) {
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
      height: 70.0,
      width: 56.0,
      alignment: Alignment.topCenter,
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: Interval(
            0.0,
            1.0 - (widget.longPressImages!.length - index) / widget.longPressImages!.length / 2.0,
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
      child: (_expandable && !_open || !_expandable) ? widget.pressImage : const Icon(Icons.close),
    );
  }
}
