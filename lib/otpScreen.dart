import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pmpml_app/MapScreen.dart';
import 'package:pmpml_app/constant/constant_ui.dart';
import 'package:pmpml_app/screens/home_screen.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key, required this.verificationId});
  final String verificationId;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final otpController = TextEditingController();
  bool isLoading = false;
  String errorMessage = ""; // Display error messages if OTP verification fails.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "otp_instruction".tr, // Using translation key
                textAlign: TextAlign.center,
                style: titleTextStyle,
              ),
              const SizedBox(height: 40),

              // OTP Input Field
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: inputDecorationStyle.copyWith(
                  hintText: "enter_otp".tr, // Using translation key
                ),
              ),
              const SizedBox(height: 20),

              // Error Message Display
              if (errorMessage.isNotEmpty)
                Text(
                  "invalid_otp".tr, // Using translation key instead of error message
                  style: errorTextStyle,
                ),
              const SizedBox(height: 20),
              
              // Verify Button
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                          errorMessage = ""; // Clear any previous error
                        });

                        try {
                          // Create a credential with the OTP provided
                          final PhoneAuthCredential credential =
                              PhoneAuthProvider.credential(
                            verificationId: widget.verificationId,
                            smsCode: otpController.text.trim(),
                          );

                          // Sign in the user using the credential
                          await FirebaseAuth.instance.signInWithCredential(credential);

                          // Show GetX success message
                          Get.snackbar(
                            "success".tr, // Using translation key
                            "sign_in_success".tr, // Using translation key
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                            borderRadius: 10,
                            margin: const EdgeInsets.all(10),
                            duration: const Duration(seconds: 3),
                          );

                          // Navigate to the map screen after successful sign-in
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        } catch (e) {
  log(e.toString());
  setState(() {
    isLoading = false;
     // Using translation key
  });

  // Show GetX error message from top in red color
  Get.snackbar(
    "error".tr, // Title using translation key
    "invalid_otp".tr, // Message using translation key
    snackPosition: SnackPosition.TOP, // Display from top side
    backgroundColor: Colors.red, // Red background for error
    colorText: Colors.white, // White text color
    borderRadius: 10,
    margin: const EdgeInsets.all(10),
    duration: const Duration(seconds: 3),
    icon: const Icon(Icons.error, color: Colors.white), // Error icon
  );
}

                      },
                      style: primaryButtonStyle,
                      child: Text("verify".tr), // Using translation key
                    ),
            ],
          ),
        ),
      ),
    );
  }
}