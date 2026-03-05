import 'package:flutter/material.dart';
import 'package:airly_app/models/city.dart';

class CitiesListPage extends StatelessWidget {
  final List<City> cities;
  final void Function(City city) onCityTap;

  const CitiesListPage({
    super.key,
    required this.cities,
    required this.onCityTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemCount: cities.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final city = cities[index];

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onCityTap(city),
          child: Container(
            height: 120,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            alignment: Alignment.centerLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  city.name,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 35,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CitesListPage extends CitiesListPage {
  const CitesListPage({
    super.key,
    required super.cities,
    required super.onCityTap,
  });
}
