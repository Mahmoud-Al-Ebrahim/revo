import 'package:flutter/material.dart';
import 'package:reddit/features/on%20boarding/page_view_body.dart';
import 'package:reddit/features/on%20boarding/page_view_button.dart';
import 'package:reddit/features/on%20boarding/page_view_indicator.dart';
import 'package:reddit/features/on%20boarding/page_view_skip_button.dart';

import 'back_ground_gradient.dart';

class OnBoardingScreen extends StatefulWidget {
  static const String routeName = '/OnBoardingScreen';

  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late final PageController myPageController;
  final ValueNotifier<int> currentPageInPageView = ValueNotifier(0);

  @override
  void initState() {
    // TODO: implement initState
    myPageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    myPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackGroundGradient(),
          Column(
            children: [
              const Spacer(),
              PageViewBody(myPageController: myPageController , currentPageInPageView : currentPageInPageView),
              const Spacer(),
              ValueListenableBuilder<int>(
                  valueListenable: currentPageInPageView,
                  builder: (context, currentPage, _) {
                    return PageViewIndicator(currentPage: currentPage);
                  }
              ),
              const Spacer(),
              ValueListenableBuilder<int>(
                  valueListenable: currentPageInPageView,
                  builder: (context, currentPage, _) {
                    return PageViewButton(
                      myPageController: myPageController,
                      currentPage: currentPage,);
                  }
              ),
              SizedBox(height: 10,),
              PageViewSkipButton(),
              const Spacer(),
            ],
          )
        ],
      ),
    );
  }
}
