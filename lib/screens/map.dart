import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/city.dart';
import '../services/city_weather_icon_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final MapController _mapController = MapController();

  List<City> _cities = [];
  final List<Marker> _markers = [];

  // Cache so we don't refetch again if user returns to this screen
  final Map<String, WeatherIconType> _iconCache = {};

  @override
  void initState() {
    super.initState();
    _loadCitiesThenMarkers();
  }

  Future<void> _loadCitiesThenMarkers() async {
    final raw = await rootBundle.loadString('assets/cities_mk.json');
    final List data = jsonDecode(raw);

    final cities = data.map((e) => City.fromJson(e)).toList();

    setState(() {
      _cities = cities;
      _markers.clear(); // clear old markers
    });

    // Build markers gradually so UI doesn't freeze
    for (final city in cities) {
      final iconType = await _getCityIconType(city);
      final marker = _buildMarker(city, iconType);

      if (!mounted) return;
      setState(() => _markers.add(marker));
    }
  }

  Future<WeatherIconType> _getCityIconType(City city) async {
    // cache key could be name or lat/lon
    final key = city.name;

    if (_iconCache.containsKey(key)) return _iconCache[key]!;

    final iconType = await CityWeatherIconService.fetchIconType(
      lat: city.lat,
      lon: city.lon,
    );

    _iconCache[key] = iconType;
    return iconType;
  }

  Marker _buildMarker(City city, WeatherIconType iconType) {
    final String assetPath = switch (iconType) {
      WeatherIconType.sun => 'assets/map_icons/weather_sunny.png',
      WeatherIconType.cloud => 'assets/map_icons/weather_cloudy.png',
      WeatherIconType.rain => 'assets/map_icons/weather_rainy.png',
       WeatherIconType.storm => 'assets/map_icons/weather_storm.png',
      WeatherIconType.snow => 'assets/map_icons/weather_snow.png',
    };

    return Marker(
      width: 100,
      height: 100,
      point: LatLng(city.lat, city.lon),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(context, '/details', arguments: city);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(assetPath, width: 38, height: 38),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                city.name,
                style: const TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 228, 234, 245)),
        
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(41.9973, 21.4280),
          initialZoom: 7,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.airly_app',
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}