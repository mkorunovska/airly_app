import 'package:airly_app/services/app_state.dart';
import 'package:airly_app/widgets/circle_stack.dart';
import 'package:airly_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  Future<void> _requestLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled")),
      );
      return;
    }

    // Check current permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location permission permanently denied. Enable it in settings.",
          ),
        ),
      );
      return;
    }

    // Permission granted → navigate
    if (!mounted) return;
    Navigator.pushNamed(context, "/details");
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 8, 9, 42),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleStack(icon: Icons.location_on_outlined),

            SizedBox(height: 170),

            Text(
              t.t('find_city_title'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 15),

            Text(
              t.t('find_city_desc'),
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
                final ok = await AppState.instance.ensureLocationAndUpdate();

                if (!mounted) return;

                if (ok) {
                  Navigator.pushNamed(
                    context,
                    "/details",
                  ); // or "/summary" (whatever you use)
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Enable GPS and allow location permission.",
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(260, 45),
                backgroundColor: const Color.fromARGB(255, 245, 249, 255),
              ),
              child: Text(
                t.t('locate_me'),
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
              onPressed: () async {
                final pres = await SharedPreferences.getInstance();
                await pres.setBool("location", true);

                if (!mounted) return;

                Navigator.pushReplacementNamed(context, '/details');
              },
              child: Text(
                t.t('decline'),
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
