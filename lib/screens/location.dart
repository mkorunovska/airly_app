import 'package:airly_app/widgets/circle_stack.dart';
import 'package:flutter/material.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 8, 9, 42),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleStack(icon: Icons.location_on_outlined),

            SizedBox(height: 170),

            Text(
              "Let's find your city",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 15),

            Text(
              "In order to do so we will need to use your phone's GPS",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w200,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/details");
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(260, 45),
                backgroundColor: const Color.fromARGB(255, 245, 249, 255),
              ),
              child: Text(
                "LOCATE ME",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Color.fromARGB(255, 8, 9, 42),
                ),
              ),
            ),

            SizedBox(height: 10),

            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, "/details");
              },
              child: Text(
                "DECLINE",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Color.fromARGB(255, 247, 248, 253),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
