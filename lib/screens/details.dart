import 'dart:ui';

import 'package:flutter/material.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  int _selectedIndex = 0;

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.pushNamed(context, "/cities");
    } else if (index == 2) {
      Navigator.pushNamed(context, "/map");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> parameters = ['pm10', 'pm25', 'humidity', 'wind'];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 8, 9, 42),
      extendBodyBehindAppBar: true,

      // appBar: AppBar(
      //   automaticallyImplyActions: false,
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   systemOverlayStyle: SystemUiOverlayStyle(
      //     statusBarBrightness: Brightness.dark,
      //   ),
      // ),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 228, 234, 245),
                  ),
                ),
              ),

              Align(
                alignment: const AlignmentDirectional(-10, -0.3),
                child: Container(
                  height: 300,
                  width: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color.fromARGB(255, 228, 234, 245),
                  ),
                ),
              ),

              Align(
                alignment: const AlignmentDirectional(0, -1.2),
                child: Container(
                  height: 300,
                  width: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: const Color.fromARGB(255, 227, 204, 167),
                  ),
                ),
              ),

              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 150.0, sigmaY: 150.0),
                child: Container(
                  decoration: BoxDecoration(color: Colors.transparent),
                ),
              ),

              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //BACKEND VREDNOST ZA GRAD
                    Text("📍 Skopje", style: TextStyle(color: Colors.white)),

                    SizedBox(height: 20),

                    Text(
                      "Good Morning",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),

                    Image.asset("assets/images/8.png"),

                    //BACKEND VREDNOST ZA TEMPERARTURA
                    Center(
                      child: Text(
                        "12℃",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 65,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    //OSTAVI GO OVA
                    Center(
                      child: Text(
                        "CLOUDY",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    //OSTAVI GO OVA
                    Center(
                      child: Text(
                        "Thursday 29 • 22.55pm",
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    //BACKEND VREDNOSTI ZA PM10, PM25, VETER i VLAZNOST
                    SizedBox(height: 60),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              "pm 10",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.white),
                            const SizedBox(width: 5),
                            Text("pm25", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.white),
                            const SizedBox(width: 5),
                            Text(
                              "humidity",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.white),
                            const SizedBox(width: 5),
                            Text("wind", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),

                    //IGNOREE !!!!!!!!!
                    // Expanded(
                    //   child: GridView.builder(
                    //     shrinkWrap: true,
                    //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //       crossAxisCount: 2,
                    //       mainAxisSpacing: 10,
                    //       crossAxisSpacing: 10,
                    //       childAspectRatio: 1.0,
                    //     ),
                    //     itemCount: parameters.length,
                    //     itemBuilder: (context, index) {
                    //       final param = parameters[index];
                    //       return Container(
                    //         width: 100,
                    //         height: 200,
                    //         decoration: BoxDecoration(
                    //           color: const Color.fromARGB(255, 237, 218, 197),
                    //           borderRadius: BorderRadius.circular(10),
                    //         ),
                    //         child: Text(
                    //           param,
                    //           style: const TextStyle(color: Colors.black),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
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
