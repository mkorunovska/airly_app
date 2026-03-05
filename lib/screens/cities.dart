import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:airly_app/l10n/app_localizations.dart';
import 'package:airly_app/models/city.dart';
import 'package:airly_app/widgets/cites_list.dart';

class CitiesPage extends StatefulWidget {
  const CitiesPage({super.key});

  @override
  State<CitiesPage> createState() => _CitiesPageState();
}

class _CitiesPageState extends State<CitiesPage> {
  int _selectedIndex = 1;

  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  List<City> _allCities = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCities();
    _searchCtrl.addListener(() {
      setState(() => _query = _searchCtrl.text);
    });
  }

  Future<void> _loadCities() async {
    try {
      const path = 'assets/cities_mk.json';

      final raw = await rootBundle.loadString(path);
      final List data = jsonDecode(raw) as List;

      final cities = data
          .map((e) => City.fromJson(e as Map<String, dynamic>))
          .toList();

      cities.sort((a, b) => a.name.compareTo(b.name)); // optional

      setState(() {
        _allCities = cities;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  List<City> get _filteredCities {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _allCities;
    return _allCities.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  void _openCity(City city) {
    Navigator.pushNamed(context, '/details', arguments: city);
  }

  void _navigateBottomBar(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      // MY LOCATION
      Navigator.pushNamed(
        context,
        "/details",
        arguments: null, // null = use GPS
      );
    } else if (index == 2) {
      Navigator.pushNamed(context, "/map");
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 8, 9, 42),
              Color.fromARGB(255, 199, 216, 230),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Text(
              "Pick a Location",
              style: TextStyle(
                fontFamily: "Manrope",
                fontSize: 30,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            Text(
              "Find the city that you want to explore",
              style: TextStyle(
                fontFamily: "Manrope",
                fontSize: 14,
                fontWeight: FontWeight.w200,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: t.t('search_hint'),
                  hintStyle: const TextStyle(
                    fontFamily: "Manrope",
                    color: Colors.white,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  
                ),
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_error != null)
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          "Failed to load cities:\n$_error",
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : CitiesListPage(
                      cities: _filteredCities,
                      onCityTap: _openCity,
                    ),
            ),
          ],
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
