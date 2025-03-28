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

/// Main Application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bottom Navigation Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Start with the Explore page.
      home: const Explore(),
    );
  }
}

/// Dummy Page: Explore
class Explore extends StatelessWidget {
  const Explore({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: const Center(child: Text('Explore Page')),
      bottomNavigationBar: const BottomNavBar(),
    );
}

/// Dummy Page: Album
class Album extends StatelessWidget {
  const Album({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Album')),
      body: const Center(child: Text('Album Page')),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

/// Dummy Page: Inbox
class InboxPage extends StatelessWidget {
  const InboxPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inbox')),
      body: const Center(child: Text('Inbox Page')),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

/// Dummy Page: Profile
class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile Page')),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

/// Constants for colors.
/// Feel free to adjust these values.
const Color CTEXT = Colors.white;
const Color CBACKGROUND3 = Colors.blue;
const Color TEXT_DISABLED3 = Colors.grey;

/// A simple function to mimic your AppFonts.lexend.
/// Adjust font family and other parameters as needed.
TextStyle lexend(double size, FontWeight weight, Color color) {
  return TextStyle(fontSize: size, fontWeight: weight, color: color);
}

/// Bottom navigation bar widget.
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});
  @override
  State createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  // Index to keep track of the currently selected tab.
  // Initially set to -1 so that no item is highlighted.
  late int _selectedIndex;

  // List of pages for navigation.
  final List<Widget> _pages = const [
    Explore(),
    Album(),
    InboxPage(),
    UserProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = -1;
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: CTEXT,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.r,
      height: 80.h,
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomNavigationItem(Icons.travel_explore, 'Explore', 0),
            _buildBottomNavigationItem(Icons.photo_album, 'Album', 1),
            SizedBox(width: 48.w), // The gap for the notch
            _buildBottomNavigationItem(Icons.chat, 'Inbox', 2),
            _buildBottomNavigationItem(Icons.person_outline, 'Profile', 3),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? CBACKGROUND3 : TEXT_DISABLED3;

    return SizedBox(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          // Navigate to the selected page.
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => _pages[index]),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon size constraints.
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 24.h,
              ),
              child: Icon(icon, color: color, size: 20.h),
            ),
            SizedBox(height: 4.h),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 24.h,
              ),
              child: Text(
                label,
                style: lexend(12.sp, FontWeight.w500, color),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
