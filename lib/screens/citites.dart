import 'package:airly_app/widgets/cites_list.dart';
import 'package:airly_app/widgets/city_container.dart';
import 'package:flutter/material.dart';

class CitiesPage extends StatefulWidget {
  const CitiesPage({super.key});

  @override
  State<CitiesPage> createState() => _CitesPageState();
}

class _CitesPageState extends State<CitiesPage> {
  int _selectedIndex = 1;
  List<String> cities = ['Skopje', 'Bitola', 'Ohrid', 'Kumanovo', 'Tetovo'];

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamed(context, "/details");
    } else if (index == 2) {
      Navigator.pushNamed(context, "/map");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 8, 9, 42),
              const Color.fromARGB(255, 199, 216, 230),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for a meal',
                  hintStyle: TextStyle(fontFamily: "Manrope"),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            Expanded(child: CitesListPage()),
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
            icon: Icon(Icons.location_on),
            label: "My Location",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_city),
            label: "All",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
        ],
      ),
    );
  }
}
