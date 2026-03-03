import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _routeAfterSplash();
  }

  Future<void> _routeAfterSplash() async {
    // Splash delay (keep/remove as you like)
    await Future.delayed(const Duration(seconds: 3));

    final prefs = await SharedPreferences.getInstance();

    final onboardingDone = prefs.getBool("onboarding") ?? false;
    final notificationDone = prefs.getBool("notification") ?? false;
    final locationDone = prefs.getBool("location") ?? false;

    if (!mounted) return;

    if (!onboardingDone) {
      Navigator.pushReplacementNamed(context, "/introduction");
    } else if (!notificationDone) {
      Navigator.pushReplacementNamed(context, "/notification");
    } else if (!locationDone){
      Navigator.pushReplacementNamed(context, "/location"); // or your real home page
    }else{
      Navigator.pushReplacementNamed(context, "/details");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 249, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo3.png"),
            const Text("Airly", style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}