import 'package:flutter/material.dart';
import 'active_circle.dart';
import 'inactive_circle.dart';

class PageViewIndicator extends StatelessWidget {
  const PageViewIndicator({super.key, required this.currentPage});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          currentPage == 0 ? const ActiveCircle() : const InactiveCircle(),
          currentPage == 1 ? const ActiveCircle() : const InactiveCircle(),
          currentPage == 2 ? const ActiveCircle() : const InactiveCircle(),
        ],
      ),
    );
  }
}
