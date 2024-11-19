
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'on_boarding_data.dart';
class PageViewBody extends StatefulWidget {
 const PageViewBody({Key? key, required this.myPageController, required this.currentPageInPageView}) : super(key: key);
  final PageController myPageController;
  final ValueNotifier<int> currentPageInPageView ;

  @override
  _PageViewBodyState createState() => _PageViewBodyState();
}

class _PageViewBodyState extends State<PageViewBody> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Expanded(
      flex: 12,
      child: PageView.builder(
        controller: widget.myPageController,
        onPageChanged: (int index){
          widget.currentPageInPageView.value = index;
        },
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(top: size.height * 0.03),
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: SvgPicture.asset(
                    onBoardingData[index].imageUrl,
                    width: size.width * 0.8,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: size.height * 0.02,
                    bottom: size.height * 0.02,
                  ),
                  child: Text(
                    onBoardingData[index].title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18)
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: size.width * 0.1, right: size.width * 0.1),
                  child: Text(
                    onBoardingData[index].description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14)
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: 3,
      ),
    );
  }
}
