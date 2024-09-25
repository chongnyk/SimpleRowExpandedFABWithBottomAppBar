import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../components/bottom/bottom_appbar.dart';
import '../components/bottom/expandable_fab.dart';
import '../components/bottom/expandable_fab_helper.dart';
import '../components/bottom/expandable_fab_overlay.dart';
import '../components/calendar/FocusedDayProvider.dart';
import '../components/route_observer.dart';
import '../constants/fonts.dart';
import '../helpers/app_fonts.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../components/calendar/calendar_top.dart';
import '../components/calendar/month_scroller.dart';
import 'calendar_cards.dart';
import 'calendar_fleets.dart';
import 'calendar_happy_days.dart';
import 'calendar_week.dart';
import '../components/calendar/calendar_navigator.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => CalendarState();
}

class CalendarState extends State<Calendar> with RouteAware {
  late DateTime _focusedDay;
  bool _showOverlay = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  void didChangeDependencies(){
    super.didChangeDependencies();
    final route = getPageRoute(context);
    if(route != null)
      routeObserver.subscribe(this, route);
    else;
      //TODO: under else, log message saying that your current widget is not associated w a route, in a context where ModalRoute hasn't been set yet, or in a non-modal route
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  //When page appears vv
  @override
  void didPush(){
    setState(() {
      _showOverlay = true;
    });
  }

  @override
  void didPopNext(){
    setState(() {
      _showOverlay = true;
    });
  }

  //When page disappears vv
  @override
  void didPop(){
    setState(() {
      _showOverlay = false;
    });
  }

  @override
  void didPushNext(){
    setState(() {
      _showOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F8F5),
      body: SafeArea(
        child: ChangeNotifierProvider(
          create: (context) => FocusedDayProvider(),
          child: Column(
            children: [
              Consumer<FocusedDayProvider>(
                builder: (context, focusedDayProvider, child) {
                  return CalendarTop(
                    //imageUrl: 'https://picsum.photos/500/300?random=${DateTime.now().millisecondsSinceEpoch}',
                    focusedDay: focusedDayProvider.focusedDay,
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  children: [
                    Consumer<FocusedDayProvider>(
                      builder: (context, focusedDayProvider, child) {
                        return ScrollableMonthList(
                          focusedDay: focusedDayProvider.focusedDay,
                          onMonthSelected: (int monthIndex) {
                            focusedDayProvider.updateFocusedMonth(monthIndex);
                          },
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (index) {
                        List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

                        return Container(
                          height: 20.h,
                          width: 55.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Color(0xFFF9F8F5),
                          ),
                          child: Center(
                            child: Container(
                              height: 20.h,
                              width: 48.w,
                              alignment: Alignment.bottomCenter,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F8F5),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                days[index],
                                style: AppFonts.lexend(16.sp, W500, Color(0xFF9A9891)),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    Consumer<FocusedDayProvider>(
                      builder: (context, focusedDayProvider, child) {
                        return TableCalendar(
                          rowHeight: 64,
                          focusedDay: focusedDayProvider.focusedDay,
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          daysOfWeekHeight: 40,
                          headerVisible: false,
                          daysOfWeekVisible: false,
                          /*
                              daysOfWeekStyle: DaysOfWeekStyle(
                                decoration: const UnderlineTabIndicator(
                                  insets: EdgeInsets.only(bottom: 6),
                                  borderSide: BorderSide(width: 1.0, color: Colors.white),
                                ),
                                dowTextFormatter: (date, locale) =>
                                    DateFormat.E(locale).format(date).substring(0, 3),
                              ),
                              */
                          onPageChanged: (newFocusedDay) {
                            focusedDayProvider.updateFocusedDay(newFocusedDay);
                          },
                          calendarBuilders: CalendarBuilders(
                            todayBuilder: (context, day, focusedDay) =>
                                calendarGrid(day, focusedDay),
                            outsideBuilder: (context, day, focusedDay) =>
                                calendarGrid(day, focusedDay),
                            defaultBuilder: (context, day, focusedDay) =>
                                calendarGrid(day, focusedDay),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: expandableFabHelper.buildExpandableFabNav(
        context,
        _showOverlay,
        true,
        CalendarHappyDays(),
        [
          CalendarHappyDays(),
          CalendarFleets(),
          CalendarCards(),
        ],
        Image.asset('assets/images/iconcal_black.png', width: 24.0, height: 24.0,),
        [
          Image.asset('assets/images/cal_happy_days.png', width: 24.0, height: 24.0,),
          Image.asset('assets/images/cal_fleets.png', width: 24.0, height: 24.0,),
          Image.asset('assets/images/cal_cards.png', width: 24.0, height: 24.0,),
        ],
      ),
    );
  }

  // Helper widget for calendar grid items
  Widget calendarGrid(DateTime day, DateTime focusedDay) {
    final bool hasEvent = Random().nextBool();

    return GestureDetector(
      onTap: () {
        print('Tapped on $day');
        Navigator.push(context, MaterialPageRoute(builder: (context) => CalendarWeek(selectedDay: day,),));
      },
      child: Container(
        height: 68.h,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFFEFEFE), width: 2.h), top: BorderSide(color: Color(0xFFFEFEFE), width: 2.h)),
          //border: Border.all(color: Colors.blue, width: 1.0),
          //: BorderRadius.circular(12.r),
          color: const Color(0xFFF9F8F5),
        ),
        child: hasEvent
            ? Stack(
          children: [
            Center(
              child: Container(
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(width: 1.0, color: Colors.white),
                  image: DecorationImage(
                    image: NetworkImage('https://picsum.photos/200/300?random=${day.day}'),
                    fit: BoxFit.cover,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.only(left: 2.w, right: 2.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: Text(day.day.toString(), style: AppFonts.lexend(12.sp, W500, Color(0xFF6C757D))),
              ),
            ),
          ],
        )
            : Center(
          child: Text(
            day.day.toString(),
            style: AppFonts.lexend(16.sp, W400, Color(0xFF263238)),
          ),
        ),
      ),
    );
  }
}

/* Discarded, this was the representation of individual calendar cells for a clean look
      child: Column(
        children: [
          Container(
            height: 36,
            alignment: Alignment.center,
            decoration: hasEvent
                ? BoxDecoration(
              border: Border.all(width: 1.0, color: Colors.white),
              image: DecorationImage(
                image: NetworkImage('https://picsum.photos/200/300?random=${day.day}'),
                fit: BoxFit.cover,
              ),
              shape: BoxShape.circle,
            )
                : const BoxDecoration(shape: BoxShape.circle),
          ),
          const SizedBox(height: 4),
          Text(
            day.day.toString(),
          ),
        ],
      ),
      */


/* Discarded: This version does not have sync b/w Calendar & ScrollableMonthList
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../components/calendar/calendar_top.dart';

class Calendar extends StatefulWidget {
  const Calendar({
    super.key,
  });

  @override
  State<Calendar> createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CalendarTop(
            imageUrl: 'https://picsum.photos/500/300?random=${DateTime.now().millisecondsSinceEpoch}',
            currentMonthIndex: DateTime.now().month - 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TableCalendar(
              rowHeight: 64,
              focusedDay: DateTime.now(),
              /*
              onPageChanged: (focusedDay) {
                // TODO: implement a function to change body above calendar based on focusedDay, (change reflected in picture and monthsBar)
              },
              */
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              daysOfWeekHeight:
              40, // 28+12 based on Figma as the gap between daysOfWeek and Rows cannot be set
              headerVisible: false,
              daysOfWeekStyle: DaysOfWeekStyle(
                //weekdayStyle: AppFonts.lexend12W500Lh20(),
                //weekendStyle: AppFonts.lexend12W500Lh20(),
                decoration: UnderlineTabIndicator(
                  insets: EdgeInsets.only(bottom: 6),
                  borderSide: BorderSide(width: 1.0, color: Colors.white),
                ),
                dowTextFormatter: (date, locale) =>
                  DateFormat.E(locale).format(date).substring(0, 1),
              ),
              calendarBuilders: CalendarBuilders(
                todayBuilder: (context, day, focusedDay) =>
                  calendarGrid(day, focusedDay),
                outsideBuilder: (context, day, focusedDay) =>
                  calendarGrid(day, focusedDay),
                defaultBuilder: (context, day, focusedDay) =>
                  calendarGrid(day, focusedDay)),
            ),
          ),
        ],
      ),
    );
  }

  Widget calendarGrid(DateTime day, DateTime focusedDay) {
    bool hasEvent = Random().nextBool();

    return Container(
      //padding: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
         //IMPORTANT NOTE: PLEASE UNCOMMENT THIS BLOCK TO SEE THE BLUE BORDERS AGAIN
        border: Border.all(
          color: Colors.blue, // Outline color
          width: 1.0, // Outline width
        ),
        borderRadius: BorderRadius.circular(12.0), // Optional: Rounded corners

        color: Color(0xFFF9F8F5),
      ),
      child: Column(
        children: [
          Container(
            height: 36,
            alignment: Alignment.center,
            decoration: hasEvent
                ? BoxDecoration(
                    border: Border.all(width: 1.0, color: Colors.white),
                    image: DecorationImage(
                      image: NetworkImage(
                          'https://picsum.photos/200/300?random=${day.day}'),
                      fit: BoxFit.cover,
                    ),
                    shape: BoxShape.circle,
                  )
                : BoxDecoration(
                    //color: AppColors().backgroundTab.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
          ),
          const SizedBox(height: 4),
          Text(
            day.day.toString(),
            //style: AppFonts.lexend12W500(),
          ),
        ],
      ),
    );
  }
}
*/
//Discard
/* headerStyle property from TableCalendar
              headerStyle: HeaderStyle(
                titleCentered: false,
                titleTextFormatter: (DateTime date, dynamic locale) =>
                    DateFormat.MMMM(locale).format(date),
                formatButtonVisible: false,
                //titleTextStyle:
                //AppFonts.lexend20W500(), //To update the title text style
                leftChevronVisible: false,
                rightChevronVisible: false,
              ),
              */
