import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class IntorPage3 extends StatelessWidget {
  const IntorPage3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 251, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.network(
              'https://lottie.host/0c01d12d-9ed1-42af-ab7a-d8fd965825e6/dsZTqsqspd.json',
              height: 300,
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                "Set up notifications tailored to your daily habits.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
