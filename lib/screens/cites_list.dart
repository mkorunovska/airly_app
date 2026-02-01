import 'package:flutter/material.dart';

class CitesListPage extends StatefulWidget {
  const CitesListPage({super.key});

  @override
  State<CitesListPage> createState() => _CitesListPageState();
}

class _CitesListPageState extends State<CitesListPage> {
  int _selectedIndex = 1;

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
      body: Center(child: Text("Cities List")),

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
