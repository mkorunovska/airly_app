import 'dart:ui';
import 'dart:async';
import 'package:airly_app/l10n/app_localizations.dart';
import 'package:airly_app/models/city.dart';
import 'package:airly_app/models/hourly_point.dart';
import 'package:airly_app/models/weather_bundle.dart';
import 'package:airly_app/services/app_state.dart';
import 'package:airly_app/services/weather_service.dart';
import 'package:airly_app/widgets/language_toggle.dart';
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:airly_app/services/notification_service.dart';

enum PmStatus { green, yellow, red }

PmStatus statusForPm25(double v) {
  if (v < 15) return PmStatus.green;
  if (v < 35) return PmStatus.yellow;
  return PmStatus.red;
}

PmStatus statusForPm10(double v) {
  if (v < 30) return PmStatus.green;
  if (v < 60) return PmStatus.yellow;
  return PmStatus.red;
}

bool isWorse(PmStatus oldS, PmStatus newS) => newS.index > oldS.index;

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  int _selectedIndex = 0;

  Future<WeatherBundle>? _bundleFuture;
  City? _lastCity;

  PmStatus? _lastNotifiedPm25;
  PmStatus? _lastNotifiedPm10;

  Timer? _pmTimer;
  WeatherBundle? _lastBundle;

  Future<void> checkAndNotifyAndLog({
    required double pm25,
    required double pm10,
    required double lat,
    required double lon,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final old25 = PmStatus.values[prefs.getInt('pm25_status') ?? 0];
    final old10 = PmStatus.values[prefs.getInt('pm10_status') ?? 0];

    final new25 = statusForPm25(pm25);
    final new10 = statusForPm10(pm10);

    final alreadyNotified25 = (_lastNotifiedPm25 == new25);
    final alreadyNotified10 = (_lastNotifiedPm10 == new10);

    if (!alreadyNotified25 && isWorse(old25, new25) && new25 == PmStatus.red) {
      _lastNotifiedPm25 = new25;

      await NotificationService.showAlarm(
        title: 'PM2.5 alert (RED)',
        body: 'PM2.5 is ${pm25.toStringAsFixed(1)} at your location.',
      );

      await FirebaseFirestore.instance.collection('alerts').add({
        'type': 'pm25',
        'from': old25.name,
        'to': new25.name,
        'value': pm25,
        'lat': lat,
        'lon': lon,
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'foreground',
      });
    }

    if (!alreadyNotified10 && isWorse(old10, new10) && new10 == PmStatus.red) {
      _lastNotifiedPm10 = new10;

      await NotificationService.showAlarm(
        title: 'PM10 alert (RED)',
        body: 'PM10 is ${pm10.toStringAsFixed(1)} at your location.',
      );

      await FirebaseFirestore.instance.collection('alerts').add({
        'type': 'pm10',
        'from': old10.name,
        'to': new10.name,
        'value': pm10,
        'lat': lat,
        'lon': lon,
        'createdAt': FieldValue.serverTimestamp(),
        'source': 'foreground',
      });
    }

    await prefs.setInt('pm25_status', new25.index);
    await prefs.setInt('pm10_status', new10.index);
  }

  void _startPmTimerIfNeeded() {
    if (_pmTimer != null) return;

    _pmTimer = Timer.periodic(const Duration(seconds: 15), (_) async {
      final pos = AppState.instance.position.value;
      final lat = _lastCity?.lat ?? pos?.latitude ?? 41.9981;
      final lon = _lastCity?.lon ?? pos?.longitude ?? 21.4254;

      final fresh = await WeatherService.fetchHourlyBundle(lat: lat, lon: lon);
      _lastBundle = fresh;

      final pm10 = _valueForNow(fresh.pm10);
      final pm25 = _valueForNow(fresh.pm25);

      if (pm10 != null && pm25 != null) {
        await checkAndNotifyAndLog(pm25: pm25, pm10: pm10, lat: lat, lon: lon);
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pmTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final City? selectedCity =
        ModalRoute.of(context)?.settings.arguments as City?;

    final changed =
        (_lastCity?.name != selectedCity?.name) ||
        (_lastCity?.lat != selectedCity?.lat) ||
        (_lastCity?.lon != selectedCity?.lon);

    if (_bundleFuture == null || changed) {
      _lastCity = selectedCity;
      _bundleFuture = _loadBundle(selectedCity);
    }
  }

  Future<WeatherBundle> _loadBundle(City? selectedCity) async {
    if (selectedCity != null) {
      return WeatherService.fetchHourlyBundle(
        lat: selectedCity.lat,
        lon: selectedCity.lon,
      );
    }

    final pos = AppState.instance.position.value;
    final lat = pos?.latitude ?? 41.9981;
    final lon = pos?.longitude ?? 21.4254;

    return WeatherService.fetchHourlyBundle(lat: lat, lon: lon);
  }

  void _navigateBottomBar(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      Navigator.pushNamed(context, "/details", arguments: null);
    } else if (index == 1) {
      Navigator.pushNamed(context, "/cities");
    } else if (index == 2) {
      Navigator.pushNamed(context, "/map");
    }
  }

  String _getGreeting(AppLocalizations t) {
    final hour = DateTime.now().hour;
    if (hour < 12) return t.t('good_morning');
    if (hour < 18) return t.t('good_afternoon');
    return t.t('good_evening');
  }

  String _getWeekdayName(int weekday, AppLocalizations t) {
    switch (weekday) {
      case DateTime.monday:
        return t.t('monday');
      case DateTime.tuesday:
        return t.t('tuesday');
      case DateTime.wednesday:
        return t.t('wednesday');
      case DateTime.thursday:
        return t.t('thursday');
      case DateTime.friday:
        return t.t('friday');
      case DateTime.saturday:
        return t.t('saturday');
      case DateTime.sunday:
        return t.t('sunday');
      default:
        return t.t('unknown');
    }
  }

  String _getFormattedDateTime(AppLocalizations t) {
    final now = DateTime.now();
    final dayName = _getWeekdayName(now.weekday, t);
    final day = now.day;
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return "$dayName $day • $hour:$minute";
  }

  String _getWeatherText(double? code, AppLocalizations t) {
    if (code == null) return t.t('unknown');

    final c = code.toInt();

    if (c == 0) return t.t('sunny');
    if ([1, 2, 3].contains(c)) return t.t('cloudy');
    if ([45, 48].contains(c)) return t.t('cloudy');
    if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82].contains(c)) {
      return t.t('rainy');
    }
    if ([71, 73, 75, 77, 85, 86].contains(c)) return t.t('snow');
    if ([95, 96, 99].contains(c)) return t.t('storm');

    return t.t('unknown');
  }

  bool _isNightNow() {
    final hour = DateTime.now().hour;
    return hour >= 19 || hour < 6;
  }

  String _getWeatherAsset(double? code) {
    if (_isNightNow()) return 'assets/images/weather_night.png';

    if (code == null) return 'assets/images/8.png';

    final c = code.toInt();

    if (c == 0) return 'assets/images/weather_sunny.png';

    if ([1, 2, 3, 45, 48].contains(c)) {
      return 'assets/images/8.png';
    }

    if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82].contains(c)) {
      return 'assets/images/weather_rainy.png';
    }

    if ([71, 73, 75, 77, 85, 86].contains(c)) {
      return 'assets/images/weather_snow.png';
    }

    if ([95, 96, 99].contains(c)) {
      return 'assets/images/weather_storm.png';
    }

    return 'assets/images/8.png';
  }

  double? _valueForNow(List<HourlyPoint>? series) {
    if (series == null || series.isEmpty) return null;

    final now = DateTime.now();

    HourlyPoint? best;

    for (final p in series) {
      if (p.time.isAfter(now)) break;
      best = p;
    }

    best ??= series.first;

    return best.value;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    final cityName = _lastCity?.name ?? t.t('my_location');
    final cityText = "📍 $cityName";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 9, 42),
      extendBodyBehindAppBar: true,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 1.2 * kToolbarHeight, 40, 20),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(10, -0.3),
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 228, 234, 245),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-10, -0.3),
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 228, 234, 245),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0, -1.2),
                child: Container(
                  height: 300,
                  width: 500,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Color.fromARGB(255, 227, 204, 167),
                  ),
                ),
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 150.0, sigmaY: 150.0),
                child: Container(
                  decoration: const BoxDecoration(color: Colors.transparent),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: FutureBuilder<WeatherBundle>(
                  future: _bundleFuture,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }

                    if (snap.hasError) {
                      return Center(
                        child: Text(
                          "Error: ${snap.error}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final bundle = snap.data;

                    _lastBundle = bundle;
                    _startPmTimerIfNeeded();

                    final tempC = _valueForNow(bundle?.temperatureC);
                    final hum = _valueForNow(bundle?.humidity);
                    final wind = _valueForNow(bundle?.windSpeed);
                    final pm10 = _valueForNow(bundle?.pm10);
                    final pm25 = _valueForNow(bundle?.pm25);
                    final weatherCode = _valueForNow(bundle?.weatherCode);

                    final pos = AppState.instance.position.value;
                    final lat = pos?.latitude ?? 41.9981;
                    final lon = pos?.longitude ?? 21.4254;

                    if (pm10 != null && pm25 != null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        checkAndNotifyAndLog(
                          pm25: pm25,
                          pm10: pm10,
                          lat: lat,
                          lon: lon,
                        );
                      });
                    }

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cityText,
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _getGreeting(t),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          Image.asset(_getWeatherAsset(weatherCode)),
                          Center(
                            child: Text(
                              tempC == null
                                  ? "--℃"
                                  : "${tempC.toStringAsFixed(0)}℃",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 65,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              _getWeatherText(weatherCode, t).toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Center(
                            child: Text(
                              _getFormattedDateTime(t),
                              style: const TextStyle(
                                fontWeight: FontWeight.w200,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 60),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/images/pm.png",
                                    scale: 8,
                                  ),
                                  const SizedBox(width: 5),
                                  Column(
                                    children: [
                                      Text(
                                        "PM10",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        pm10 == null
                                            ? "--"
                                            : "${pm10.toStringAsFixed(0)} µg/m³",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/images/pm.png",
                                    scale: 8,
                                  ),
                                  const SizedBox(width: 5),
                                  Column(
                                    children: [
                                      Text(
                                        "PM2.5",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        pm25 == null
                                            ? "--"
                                            : "${pm25.toStringAsFixed(0)} µg/m³",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsetsGeometry.symmetric(vertical: 5),
                            child: Divider(
                              color: Color.fromARGB(255, 239, 238, 238),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/images/humidity.png",
                                    scale: 8,
                                  ),
                                  const SizedBox(width: 5),
                                  Column(
                                    children: [
                                      Text(
                                        "${t.t('humidity')}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        hum == null
                                            ? "--"
                                            : "${hum.toStringAsFixed(0)}%",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/images/wind.png",
                                    scale: 8,
                                  ),
                                  const SizedBox(width: 5),
                                  Column(
                                    children: [
                                      Text(
                                        "${t.t('wind')}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        wind == null
                                            ? "--"
                                            : "${wind.toStringAsFixed(0)} km/h",
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Row(
                  children: [
                    IconButton(
                      tooltip: t.t('insights'),
                      onPressed: () => Navigator.pushNamed(context, '/summary'),
                      icon: Icon(
                        Icons.insights,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const LanguageToggle(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 8, 9, 42),
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        selectedItemColor: const Color.fromARGB(255, 177, 185, 197),
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.location_on),
            label: t.t('my_location'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.location_city),
            label: t.t('all'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: t.t('map'),
          ),
        ],
      ),
    );
  }
}
