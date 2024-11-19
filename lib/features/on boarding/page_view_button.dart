import 'package:flutter/material.dart';
import 'package:reddit/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PageViewButton extends StatelessWidget {
  const PageViewButton(
      {Key? key, required this.myPageController, required this.currentPage})
      : super(key: key);
  final PageController myPageController;
  final int currentPage;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
        onTap: () async{
          if (currentPage < 2) {
            myPageController.animateToPage(currentPage + 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut);
          } else {
            final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
            sharedPreferences.setBool('user_saw_onBoarding', true);
            Routemaster.of(context).replace('/login-screen');
          }
        },
        child: Container(
          margin: EdgeInsets.only(left: size.width * 0.1, right: size.width * 0.1),
          padding: const EdgeInsets.all(10),
          decoration:  const BoxDecoration(
              color: Colors.deepOrange,
              borderRadius: BorderRadius.horizontal(
            right: Radius.circular(15),
            left: Radius.circular(15),
          )),
          width: size.width,
          child: Center(
            child: Text(
              currentPage == 2 ? 'Get Started' : 'NEXT',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ));
  }
}
