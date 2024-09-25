import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'expandable_fab.dart';
import 'expandable_fab_overlay.dart';

class expandableFabHelper {
  static Widget buildExpandableFabNav(BuildContext context, bool overlayVisible, bool longPressAvail, Widget nextPage, List<Widget>? pagesAvail, Image currentPageIcon, List<Image>? pagesAvailImages) {
    return AnchoredOverlay(
      showOverlay: overlayVisible,
      overlayBuilder: (context, offset, toggleOverlay) {
        return CenterAbout(
          position: Offset(offset.dx - 58.w, offset.dy - 71.h,),
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

  static Widget buildExpandableFabModal(BuildContext context, Widget modalBottomSheetContents, Image showBottomSheetButton) {
    return AnchoredOverlay(
      showOverlay: true,
      overlayBuilder: (context, offset, toggleOverlay) {
        return CenterAbout(
          position: Offset(offset.dx, offset.dy,),
          child: ExpandableFab.showModal(
            longPressAction: false,
            pressOption: modalBottomSheetContents,
            longPressOptions: null,
            pressImage: showBottomSheetButton,
            longPressImages: null,
            toggleOverlay: toggleOverlay,
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
