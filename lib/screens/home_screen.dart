import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pmpml_app/screens/book_ticket.dart'; 

import 'package:pmpml_app/MapScreen.dart';
import 'package:pmpml_app/constant/constant_ui.dart';
import 'package:pmpml_app/screens/place_suggestion.dart';
import 'package:pmpml_app/screens/scanner_screen.dart';
import 'package:pmpml_app/screens/ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _fromPlace;
  Map<String, dynamic>? _toPlace;
  bool _bookingForWomen = false;
  int _currentIndex = 0; // Track current selected index for bottom nav
  final RxString _errorMessage = ''.obs; // Reactive error message

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.pink],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: AppBar(
              centerTitle: true,
              backgroundColor: Colors.transparent.withOpacity(0.20),
              elevation: 50,
              title: const Text(
                'PMPML',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Get.offAll(() => UIScreen(), arguments: {'initialPage': 2});
                },
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: GradientBackground(
          child: Padding(
            padding: const EdgeInsets.only(bottom:16, right:16, left: 16),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // Error Message Display
                Obx(() {
                  if (_errorMessage.value.isNotEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.red,
                      child: Text(
                        _errorMessage.value,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return const SizedBox.shrink(); // Empty space if no error
                }),

                // From & To Input Fields
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Column(
                    children: [
                      PlaceSuggestionField(
                        hint: 'From',
                        icon: Icons.directions_bus,
                        onPlaceSelected: (place) {
                          setState(() {
                            _fromPlace = place;
                            _errorMessage.value = ''; // Clear error message
                          });
                        },
                      ),
                      const Divider(height: 1, thickness: 1),
                      PlaceSuggestionField(
                        hint: 'To',
                        icon: Icons.location_on,
                        onPlaceSelected: (place) {
                          setState(() {
                            _toPlace = place;
                            _errorMessage.value = ''; // Clear error message
                          });
                        },
                      ),
                    ],
                  ),
                ),
            

    
                const SizedBox(height: 16),

                // Booking for Women Toggle
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.woman, color: Colors.pinkAccent),
                        const SizedBox(width: 10),
                        const Text('Booking for women', style: TextStyle(fontSize: 16)),
                        const Spacer(),
                        Switch(
                          value: _bookingForWomen,
                          onChanged: (value) {
                            setState(() {
                              _bookingForWomen = value;
                            });
                          },
                          activeColor: Colors.pinkAccent,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

 // Search Button
ElevatedButton.icon(
  onPressed: () {
    if (_fromPlace != null && _toPlace != null) {
      // Navigate to MapScreen with selected places
      Get.to(() => MapScreen(
            fromPlace: _fromPlace,
            toPlace: _toPlace,
          ));
    } else {
      // Show error message using GetX Snackbar
      Get.snackbar(
        'Error', // Title
        'Please select both origin and destination locations', // Message
        snackPosition: SnackPosition.TOP, // Position of the snackbar
        backgroundColor: Colors.red, // Background color of the snackbar
        colorText: Colors.white, // Text color
        margin: const EdgeInsets.all(16), // Margin around the snackbar
        borderRadius: 8, // Border radius
        duration: const Duration(seconds: 3), // Duration for which the snackbar is shown
      );
    }
  },
  icon: const Icon(Icons.search, color: Colors.white),
  label: const Text('Search buses', style: TextStyle(fontSize: 18, color: Colors.white)),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.red,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    minimumSize: const Size(double.infinity, 50),
  ),
),
const SizedBox(height: 16),

// 2x3 Grid for Ticket and Bus Options
// 2x3 Grid for Ticket and Bus Options
GridView.count(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(), // Prevents scrolling inside GridView
  crossAxisCount: 2,
  mainAxisSpacing: 10,
  crossAxisSpacing: 10,
  childAspectRatio: 1.6, // Adjusted for smaller card size
  children: [
    _buildCard('Book Ticket', Icons.confirmation_number, Colors.red, () {
      // Navigate to BookTicketScreen if origin and destination are selected
      if (_fromPlace != null && _toPlace != null) {
        // For demonstration, using a fixed fare of 15 from your JSON
        // In a real app, you would calculate this based on the route
        Get.to(() => BookTicketScreen(
          fromPlace: _fromPlace,
          toPlace: _toPlace,
          totalFare: 15.0, // You could calculate this dynamically based on route
        ));
      } else {
        // Show error message if locations aren't selected
        Get.snackbar(
          'Error',
          'Please select both origin and destination locations',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );
      }
    }),
    _buildCard('View Ticket', Icons.receipt_long, Colors.blue, () {
      // Handle View Ticket action
    }),
    _buildCard('Bus Pass', Icons.card_membership, Colors.green, () {
      // Handle Bus Pass action
    }),
    _buildCard('View Pass', Icons.credit_card, Colors.teal, () {
      // Handle View Pass action
    }),
    
     _buildCard('Scan Upcoming Bus', Icons.qr_code_scanner, Colors.purple, () {
                      // Navigate to Scanner Screen
                      Get.to(() =>  ScannerScreen());
                    }),
    _buildCard('city Routes', Icons.map, Colors.orange, () {
      // Handle Routes action
    }),
  ],
),

   const SizedBox(height: 20),

              ],
            ),
          ),
        ),
      ),
bottomNavigationBar: BottomNavigationBar(
  currentIndex: _currentIndex,
  onTap: (index) {
    setState((){
      _currentIndex = index;
    });
    // Handle navigation based on index if needed
    switch (index ) {
      case 0: // Home
        break;
      case 1: // Bookings
        break;
      case 2: // Help
        break;
      case 3: // My Account  
        break;
    }
  },
  type: BottomNavigationBarType.fixed, // Important for more than 3 items
  selectedItemColor: Colors.red,
  unselectedItemColor: Colors.black54,
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.book),
      label: 'Bookings',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.help),
      label: 'Help',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Account',
    ),
  ],
)
    );
  }
  
Widget _buildCard(String title, IconData icon, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Reduced border radius
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: color), // Reduced icon size
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}

  // Widget for date buttons
  Widget _buildDateButton(String label, bool isSelected) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.red : Colors.grey.shade300,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(label),
    );
  }
}