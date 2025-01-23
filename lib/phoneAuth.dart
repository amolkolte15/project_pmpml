import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart'; // Import for country code selection

import 'otpScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'IN');  // Default to India (can change)
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Phone Authentication",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            // Phone input field with country code
            InternationalPhoneNumberInput(
              onInputChanged: (PhoneNumber phone) {
                setState(() {
                  number = phone;  // Update the phone number and country code
                });
              },
              onInputValidated: (bool isValid) {
                // Handle phone number validation status
              },
              selectorConfig: SelectorConfig(
                selectorType: PhoneInputSelectorType.DROPDOWN,
                setSelectorButtonAsPrefixIcon: true,
              ),
              initialValue: number,
              textFieldController: phoneController,
              inputDecoration: InputDecoration(
                fillColor: Colors.grey.withOpacity(0.25),
                filled: true,
                hintText: "Enter Phone",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            isloading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                setState(() {
                  isloading = true;
                });

                // Get the phone number (including country code)
                String phoneNumber = number.phoneNumber ?? '';
                if (phoneNumber.isEmpty || number.phoneNumber == null) {
                  setState(() {
                    isloading = false;
                  });
                  log('Phone number is invalid');
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Please enter a valid phone number.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                  return; // Do not proceed if phone number is invalid
                }

                try {
                  // Verify phone number via Firebase Auth
                  await FirebaseAuth.instance.verifyPhoneNumber(
                    phoneNumber: phoneNumber,
                    verificationCompleted: (phoneAuthCredential) {
                      // This is triggered if phone number is auto-verified
                    },
                    verificationFailed: (error) {
                      log(error.toString());
                      setState(() {
                        isloading = false;
                      });
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text('Error'),
                          content: Text(error.message ?? 'Unknown error'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        ),
                      );
                    },
                    codeSent: (verificationId, forceResendingToken) {
                      setState(() {
                        isloading = false;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OTPScreen(
                            verificationId: verificationId,
                          ),
                        ),
                      );
                    },
                    codeAutoRetrievalTimeout: (verificationId) {
                      log("Auto Retrieval timeout");
                    },
                  );
                } catch (e) {
                  setState(() {
                    isloading = false;
                  });
                  log(e.toString());
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('Error'),
                      content: Text('An error occurred during phone verification.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text(
                "Sign in",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
