import 'package:flutter/material.dart';

import '../../theme/pallete.dart';

class ActiveCircle extends StatelessWidget {
  const ActiveCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10,right: 10),
      width: 25,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(12),
          right: Radius.circular(12),
        ),
        boxShadow: [BoxShadow(
          color: Pallete.drawerColor,
          offset: Offset(0,2),
          spreadRadius: 0.2,
          blurRadius:5
        )],
      ),
    );
  }
}
