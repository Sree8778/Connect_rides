import 'package:flutter/material.dart';
import 'ride_management_page.dart';
import 'ride_requests_page.dart';
import 'profile_page.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    RideManagementPage(),
    RideRequestsPage(),

    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("College Ride Sharing"),
        ),
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed, // Ensure the items stay visible
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.local_taxi),
              label: 'Manage Rides',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Ride Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat Forum',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.deepPurple, // Optional: Change selected color
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
