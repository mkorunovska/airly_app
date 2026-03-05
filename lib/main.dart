import 'package:airly_app/screens/cities.dart';
import 'package:airly_app/screens/details.dart';
import 'package:airly_app/screens/location.dart';
import 'package:airly_app/screens/map.dart';
import 'package:airly_app/screens/notification.dart';
import 'package:airly_app/screens/on_boarding.dart';
import 'package:airly_app/screens/summary.dart';
import 'package:airly_app/screens/splash.dart';
import 'package:airly_app/l10n/app_localizations.dart';
import 'package:airly_app/services/app_state.dart';
import 'package:airly_app/services/notification_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
 
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.showFromFCM(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await NotificationService.init();

  FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler);
      
  await AppState.instance.loadPersisted();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppState.instance.locale,
      builder: (context, locale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Airly',
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          ),
          initialRoute: "/splash",
          routes: {
            '/splash': (context) => const SplashPage(),
            '/introduction': (context) => const OnBoardingPage(),
            '/notification': (context) => const NotificationPage(),
            '/location': (context) => const LocationPage(),
            '/details': (context) => const DetailsPage(),
            '/cities': (context) => const CitiesPage(),
            '/summary': (context) => const SummaryPage(),
            '/map': (context) => const MapPage(),
          },
        );
      },
    );
  }
}