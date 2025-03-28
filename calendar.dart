import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

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
      title: 'Standalone Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Calendar(),
    );
  }
}

/// A simple provider to hold and update the focused day.
class FocusedDayProvider extends ChangeNotifier {
  DateTime _focusedDay;
  FocusedDayProvider() : _focusedDay = DateTime.now();

  DateTime get focusedDay => _focusedDay;

  void updateFocusedDay(DateTime newDay) {
    _focusedDay = newDay;
    notifyListeners();
  }

  void updateFocusedMonth(int month) {
    // Create a new DateTime with the updated month, preserving the year and day.
    _focusedDay = DateTime(_focusedDay.year, month, _focusedDay.day);
    notifyListeners();
  }
}

/// A simple header widget that shows the month of the focused day.
class CalendarTop extends StatelessWidget {
  final DateTime focusedDay;
  const CalendarTop({Key? key, required this.focusedDay}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String month = DateFormat.MMMM().format(focusedDay);
    return Container(
      padding: EdgeInsets.all(16.0.w),
      child: Text(
        month,
        style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}

/// A horizontal month list that lets the user select a month.
class ScrollableMonthList extends StatelessWidget {
  final DateTime focusedDay;
  final Function(int) onMonthSelected;
  const ScrollableMonthList({
    Key? key,
    required this.focusedDay,
    required this.onMonthSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create a list of month names.
    List<String> months = List.generate(
      12,
      (index) => DateFormat.MMMM().format(DateTime(0, index + 1)),
    );

    return Container(
      height: 50.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: months.length,
        itemBuilder: (context, index) {
          bool isSelected = focusedDay.month == index + 1;
          return GestureDetector(
            onTap: () {
              onMonthSelected(index + 1);
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blueAccent : Colors.grey[300],
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Text(
                  months[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The main Calendar widget that displays a header, a month scroller,
/// the days of the week row, and a TableCalendar.
class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => CalendarState();
}

class CalendarState extends State<Calendar> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8F5),
      appBar: AppBar(title: const Text('Standalone Calendar')),
      body: SafeArea(
        child: ChangeNotifierProvider(
          create: (context) => FocusedDayProvider(),
          child: Column(
            children: [
              Consumer<FocusedDayProvider>(
                builder: (context, focusedDayProvider, child) {
                  return CalendarTop(
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
                    // Days of week header.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (index) {
                        List<String> days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                        return Container(
                          height: 20.h,
                          width: 55.w,
                          alignment: Alignment.center,
                          child: Text(
                            days[index],
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: const Color(0xFF9A9891)),
                          ),
                        );
                      }),
                    ),
                    Consumer<FocusedDayProvider>(
                      builder: (context, focusedDayProvider, child) {
                        return TableCalendar(
                          rowHeight: 64.h,
                          focusedDay: focusedDayProvider.focusedDay,
                          firstDay: DateTime.utc(2020, 1, 1),
                          lastDay: DateTime.utc(2030, 12, 31),
                          daysOfWeekHeight: 40.h,
                          headerVisible: false,
                          daysOfWeekVisible: false,
                          onPageChanged: (newFocusedDay) {
                            focusedDayProvider.updateFocusedDay(newFocusedDay);
                          },
                          calendarBuilders: CalendarBuilders(
                            todayBuilder: (context, day, focusedDay) => calendarGrid(day),
                            outsideBuilder: (context, day, focusedDay) => calendarGrid(day),
                            defaultBuilder: (context, day, focusedDay) => calendarGrid(day),
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
    );
  }

  /// Returns a widget representing an individual calendar cell.
  Widget calendarGrid(DateTime day) {
    final bool hasEvent = Random().nextBool();

    return GestureDetector(
      onTap: () {
        // Navigate to a simple week view page.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CalendarWeek(selectedDay: day),
          ),
        );
      },
      child: Container(
        height: 68.h,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: const Color(0xFFFEFEFE), width: 2.h),
            top: BorderSide(color: const Color(0xFFFEFEFE), width: 2.h),
          ),
          color: const Color(0xFFF9F8F5),
        ),
        child: hasEvent
            ? Stack(
                children: [
                  Center(
                    child: Container(
                      height: 36.h,
                      width: 36.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 1.0, color: Colors.white),
                        image: DecorationImage(
                          image: NetworkImage('https://picsum.photos/200/300?random=${day.day}'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                      child: Text(
                        day.day.toString(),
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500, color: const Color(0xFF6C757D)),
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Text(
                  day.day.toString(),
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, color: const Color(0xFF263238)),
                ),
              ),
      ),
    );
  }
}

/// A simple page to display the selected day.
/// This mimics a "week view" page.
class CalendarWeek extends StatelessWidget {
  final DateTime selectedDay;
  const CalendarWeek({Key? key, required this.selectedDay}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDay = DateFormat.yMMMd().format(selectedDay);
    return Scaffold(
      appBar: AppBar(title: const Text("Week View")),
      body: Center(
        child: Text(
          "Selected day: $formattedDay",
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
