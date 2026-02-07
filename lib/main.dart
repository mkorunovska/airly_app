import 'package:airly_app/screens/citites.dart';
import 'package:airly_app/widgets/cites_list.dart';
import 'package:airly_app/screens/details.dart';
import 'package:airly_app/screens/location.dart';
import 'package:airly_app/screens/map.dart';
import 'package:airly_app/screens/notification.dart';
import 'package:airly_app/screens/on_boarding.dart';
import 'package:airly_app/screens/splash.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: "/splash",
      routes: {
        '/splash': (context) => const SplashPage(),
        '/introduction': (context) => const OnBoardingPage(),
        '/notification': (context) => const NotificationPage(),
        '/location': (context) => const LocationPage(),
        '/details': (context) => const DetailsPage(),
        '/cities': (context) => const CitiesPage(),
        '/map': (context) => const MapPage()
      },
    );
  }
}

