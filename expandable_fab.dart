import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../pages/calendar.dart';
import '../../pages/calendar_cards.dart';
import '../../pages/calendar_fleets.dart';
import '../../pages/calendar_happy_days.dart';

class ExpandableFab extends StatefulWidget {
  final Function pressAction;
  final bool longPressAction;
  final Widget pressOption;
  final List<Widget>? longPressOptions;
  final Image pressImage;
  final List<Image>? longPressImages;
  final Function? toggleOverlay;
  final String currentPageRouteName;
  final List<Widget> calendarPages = [Calendar(), CalendarHappyDays(), CalendarFleets(), CalendarCards()];

  const ExpandableFab({
    Key? key,
    required this.pressAction,
    required this.longPressAction,
    required this.pressOption,
    this.longPressOptions,
    required this.pressImage,
    this.longPressImages,
  }) : assert(longPressAction || (longPressOptions == null && longPressImages == null),
              'If longPressAction is null, longPressOptions and longPressImages must also be null.'),
       assert((longPressOptions == null && longPressImages == null)
               || (longPressOptions != null && longPressImages != null && longPressOptions.length == longPressImages.length),
               'If either longPressOptions or longPressImages is not null, the other must be non-null and both must be same length.'),
       toggleOverlay = null,
       currentPageRouteName = '',
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

  ExpandableFab.showModal({
    Key? key,
    required bool longPressAction,
    required Widget pressOption,
    List<Widget>? longPressOptions,
    required Image pressImage,
    List<Image>? longPressImages,
    required toggleOverlay
  }) : this(
    key: key,
    pressAction: (context, pressOption) async {
      if(toggleOverlay != null) toggleOverlay!(false);

      await showModalBottomSheet(
        context: context,
        builder: (context) => pressOption,
      );

      if(toggleOverlay != null) toggleOverlay!(true);
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
    if(widget.longPressAction && widget.longPressOptions != null && widget.longPressOptions!.isNotEmpty){
      _expandable = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded(){
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _onExpandedPress(int index){
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget.longPressOptions![index]));
  }

  @override
  Widget build(BuildContext context){
    return (_expandable) ? Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
                1.0 - 0.25,
                curve: Curves.easeOut,
              ),
            ),
            child: Container(
              width: 172.w,
              height: 60.h,
              padding: EdgeInsets.symmetric(vertical: 8.h,),
              decoration: BoxDecoration(
                color: Color(0xFFFEFEFE), //TODO: Change color to defined color
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.longPressImages!.length, (int index) {
                  return _buildChild(index);
                }).toList(),
              ),
            ),
          ),
        ),
        SizedBox(height: 13.h),
        _buildFab(),
      ],
    ) : _buildFab();
  }

  Widget _buildChild(int index) {

    return Container(
      height: 70.0,
      width: 56.0,
      alignment: FractionalOffset.topCenter,
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
          fillColor: Color(0xFFFEFEFE),
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
        if(_expandable && _open){
          _toggleExpanded();
        }
        else{
          widget.pressAction(context, widget.pressOption);
        }
      },
      onLongPress: () {
        (_expandable) ? _toggleExpanded() : null;
      },
      fillColor: Color(0xFFFEFEFE),
      shape: const CircleBorder(),
      elevation: 6.0,
      constraints: BoxConstraints.tightFor(
        width: 56.w,
        height: 56.h,
      ),
      child: (_expandable && !_open || !_expandable) ? widget.pressImage : const Icon(Icons.close), //Can replace with Image.asset('path')
    );
  }
}
