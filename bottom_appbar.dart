import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/colors.dart';
import '../../constants/fonts.dart';
import '../../constants/misc.dart';
import '../../helpers/app_fonts.dart';
import '../../pages/album.dart';
import '../../pages/explore.dart';
import '../../pages/inbox.dart';
import '../../pages/profile.dart';

class BottomNavBar extends StatefulWidget {

  BottomNavBar({
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int _selectedIndex;
  final List<Widget> _pages = [
    const Explore(),
    const Album(),
    const InboxPage(),
    const UserProfilePage(),
  ];

  @override
  void initState(){
    super.initState();
    _selectedIndex = -1;
  }

  @override
  Widget build(BuildContext context){
    return BottomAppBar(
      color: CTEXT,
      shape: const CircularNotchedRectangle(),
      notchMargin: 10.r,
      height: (80).h,
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
      //height: (80).h,
      child: InkWell(
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => _pages[index])),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Maximum 24.h + 4.h + 24.h
            // In any combination, the height should not exceed 52.h
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
                child:
                Text(label, style: AppFonts.lexend(12.sp, W500, color), overflow: TextOverflow.ellipsis, maxLines: 1,)
            ),
          ],
        ),
      ),
    );
  }
}
