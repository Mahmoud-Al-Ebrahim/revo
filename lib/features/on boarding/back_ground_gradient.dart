import 'package:flutter/material.dart';

import '../../theme/pallete.dart';

class BackGroundGradient extends StatelessWidget {
  const BackGroundGradient({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Pallete.drawerColor.withOpacity(0.4),
            Pallete.drawerColor.withOpacity(0.7),
            Pallete.drawerColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
