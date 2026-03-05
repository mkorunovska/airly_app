import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppState {
  AppState._();

  static final AppState instance = AppState._();

  Future<bool> ensureLocationAndUpdate() async {
 
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) return false;

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return false;
  }

  final pos = await Geolocator.getCurrentPosition(
    
  );

  position.value = pos;
  return true;
}

  /// Current GPS position (if permission granted).
  final ValueNotifier<Position?> position = ValueNotifier<Position?>(null);

  /// Current app locale.
  final ValueNotifier<Locale> locale = ValueNotifier<Locale>(const Locale('en'));

  static const _prefsKeyLocale = 'app_locale';

  Future<void> loadPersisted() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKeyLocale);
    if (code == 'mk') {
      locale.value = const Locale('mk');
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    locale.value = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyLocale, newLocale.languageCode);
  }
}
