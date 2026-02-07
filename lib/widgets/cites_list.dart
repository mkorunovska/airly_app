import 'package:airly_app/widgets/city_container.dart';
import 'package:flutter/material.dart';

class CitesListPage extends StatefulWidget {
  const CitesListPage({super.key});

  @override
  State<CitesListPage> createState() => _CitesListPageState();
}

class _CitesListPageState extends State<CitesListPage> {
  List<String> cities = ['Skopje', 'Bitola', 'Ohrid', 'Kumanovo', 'Tetovo'];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cities.length,
      physics: BouncingScrollPhysics(),
      itemBuilder: (context, int index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: GlassContainer(
            width: 300,
            height: 150,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                cities[index],
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 32,
                  fontWeight: FontWeight.w200,
                ),
              ),
            ),
          ),
        );
      },
    );
    // );
  }
}
