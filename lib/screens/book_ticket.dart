import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:pmpml_app/constant/constant_ui.dart';

class BookTicketScreen extends StatefulWidget {
  final Map<String, dynamic>? fromPlace;
  final Map<String, dynamic>? toPlace;
  final double totalFare;

  const BookTicketScreen({
    Key? key,
    this.fromPlace,
    this.toPlace,
    required this.totalFare,
  }) : super(key: key);

  @override
  _BookTicketScreenState createState() => _BookTicketScreenState();
}

class _BookTicketScreenState extends State<BookTicketScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  int passengerCount = 1;
  bool isBookingForWomen = false;
  late Razorpay _razorpay;
  
  @override
  void initState() {
    super.initState();
    initializeRazorPay();
  }

  void initializeRazorPay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void launchRazorPay() {
    int amountToPay = (widget.totalFare * passengerCount * 100).toInt();
    
    var options = {
      'key': 'rzp_test_FSFnXQOqPP1YbJ',
      'amount': "$amountToPay",
      'name': 'PMPML Bus Ticket',
      'description': 'Ticket from ${widget.fromPlace?['name'] ?? ''} to ${widget.toPlace?['name'] ?? ''}',
      'prefill': {
        'contact': phoneController.text,
        'email': emailController.text,
        'name': nameController.text
      }
    };
    
    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error: $e");
      Get.snackbar(
        'Error',
        'Payment initialization failed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Payment Successful");
    print("${response.orderId} \n${response.paymentId} \n${response.signature}");
    
    Get.snackbar(
      'Success',
      'Payment completed successfully!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
    
    // Here you would typically update your database with ticket information
    // and navigate to a ticket confirmation screen
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Failed");
    print("${response.code}\n${response.message}");
    
    Get.snackbar(
      'Failed',
      'Payment failed. Please try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet Selected: ${response.walletName}");
    
    Get.snackbar(
      'Info',
      'External wallet selected: ${response.walletName}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double calculatedFare = widget.totalFare * passengerCount;
    bool canProceed = nameController.text.isNotEmpty && 
                      phoneController.text.isNotEmpty && 
                      emailController.text.isNotEmpty;
    
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: true,
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
                'Book Ticket',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: GradientBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Route Info Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // From location
                        Row(
                          children: [
                            const Icon(Icons.directions_bus, color: Colors.blue),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'From: ${widget.fromPlace?['name'] ?? 'Not selected'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // To location
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.red),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'To: ${widget.toPlace?['name'] ?? 'Not selected'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Fare info
                        Row(
                          children: [
                            const Icon(Icons.currency_rupee, color: Colors.green),
                            const SizedBox(width: 10),
                            Text(
                              'Fare: ₹${widget.totalFare.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Passenger Information
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Passenger Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Name field
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        
                        // Phone field
                        TextField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: const Icon(Icons.phone),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        
                        // Email field
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Booking Options
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Options',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Number of passengers
                        Row(
                          children: [
                            const Text(
                              'Number of Passengers:',
                              style: TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: passengerCount > 1
                                  ? () => setState(() => passengerCount--)
                                  : null,
                              color: Colors.red,
                            ),
                            Text(
                              '$passengerCount',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => setState(() => passengerCount++),
                              color: Colors.green,
                            ),
                          ],
                        ),
                        
                        const Divider(),
                        
                        // Booking for women toggle
                        Row(
                          children: [
                            const Icon(Icons.woman, color: Colors.pinkAccent),
                            const SizedBox(width: 10),
                            const Text('Booking for women', style: TextStyle(fontSize: 16)),
                            const Spacer(),
                            Switch(
                              value: isBookingForWomen,
                              onChanged: (value) {
                                setState(() {
                                  isBookingForWomen = value;
                                });
                              },
                              activeColor: Colors.pinkAccent,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Total Fare Display
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.blue.shade50,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Fare:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₹${calculatedFare.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Book Ticket Button
                ElevatedButton.icon(
                  onPressed: canProceed ? launchRazorPay : null,
                  icon: const Icon(Icons.payment, color: Colors.white),
                  label: const Text(
                    'Book Ticket',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _razorpay.clear();
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}