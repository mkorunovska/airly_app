import 'package:airly_app/screens/intro_screens/intro_page_3.dart';
import 'package:airly_app/screens/intro_screens/intro_page_1.dart';
import 'package:airly_app/screens/intro_screens/intro_page_2.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final PageController _controller = PageController();
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) => {
              setState(() {
                onLastPage = (index == 2);
              }),
            },
            children: [IntroPage1(), IntroPage2(), IntorPage3()],
          ),
          Container(
            alignment: Alignment(0, 0.8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    _controller.jumpToPage(2);
                  },
                  child: Text(
                    "Skip",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w200),
                  ),
                ),

                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: WormEffect(
                    activeDotColor: const Color.fromARGB(255, 10, 12, 54),
                    dotHeight: 5,
                  ),
                ),

                onLastPage
                    ? GestureDetector(
                        onTap: () async{
                          final pres = await SharedPreferences.getInstance();
                          await pres.setBool("onboarding", true);

                          if(!mounted) return;

                           Navigator.pushReplacementNamed(context, '/location');
                        },
                        child: Text(
                          "Done",
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w200),
                        ),
                      )
                    : GestureDetector(
                        onTap: () {
                          _controller.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeIn,
                          );
                        },
                        child: Text(
                          "Next", 
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w200),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
