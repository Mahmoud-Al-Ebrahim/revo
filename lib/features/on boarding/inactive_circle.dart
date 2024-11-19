import 'package:flutter/material.dart';
import 'package:reddit/theme/pallete.dart';

class InactiveCircle extends StatelessWidget {
  const InactiveCircle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10,right: 10),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
          border: Border.all(color:Pallete.greyColor),
          color: Colors.deepOrange,
        shape: BoxShape.circle
      ),
    );
  }
}
