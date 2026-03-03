import 'package:airly_app/widgets/circle_stack.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 8, 9, 42),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CircleStack(icon: Icons.notifications),

            SizedBox(height: 120),

            Text(
              'Air Quality Notifications',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 15),

            Text(
              'We need your authorization to send you alerts and pollution reports',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w200,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                final pres = await SharedPreferences.getInstance();
                await pres.setBool("notification", true);

                //After we press done, this onboarding value becomes true

                if(!mounted) return;

                Navigator.pushReplacementNamed(context, '/location');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(260, 45),
                backgroundColor: const Color.fromARGB(255, 245, 249, 255),
              ),
              child: Text(
                "ALLOW",
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
                Navigator.pushNamed(context, "/location");
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
