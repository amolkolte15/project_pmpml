import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:pmpml_app/constant/constant_ui.dart';
import 'otpScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();
  PhoneNumber number = PhoneNumber(isoCode: 'IN');
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "phone_authentication".tr, // Using translation key
                  style: titleTextStyle,
                ),
                const SizedBox(height: 40),

                // Phone number input
                InternationalPhoneNumberInput(
                  onInputChanged: (PhoneNumber phone) {
                    setState(() {
                      number = phone;
                    });
                  },
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.DROPDOWN,
                    setSelectorButtonAsPrefixIcon: true,
                  ),
                  initialValue: number,
                  textFieldController: phoneController,
                  inputDecoration: inputDecorationStyle.copyWith(
                    hintText: "enter_phone".tr, // Using translation key
                  ),
                ),
                const SizedBox(height: 20),

                // Sign-in button
                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });

                          String phoneNumber = number.phoneNumber ?? '';

                          // Only show GetX message for invalid numbers
                          if (phoneNumber.length < 10) {
                            setState(() {
                              isLoading = false;
                            });
                            Get.snackbar(
                              "invalid_number".tr, // Using translation key
                              "enter_valid_number".tr, // Using translation key
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                              duration: const Duration(seconds: 2),
                            );
                            return;
                          }

                          // Continue if valid number
                          try {
                            await FirebaseAuth.instance.verifyPhoneNumber(
                              phoneNumber: phoneNumber,
                              verificationCompleted: (phoneAuthCredential) {},
                              verificationFailed: (error) {
                                log(error.toString());
                                setState(() {
                                  isLoading = false;
                                });
                                Get.snackbar(
                                  "error".tr, // Using translation key
                                  error.message ?? 'unknown_error'.tr, // Using translation key
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              },
                              codeSent: (verificationId, forceResendingToken) {
                                setState(() {
                                  isLoading = false;
                                });
                                Get.snackbar(
                                  "success".tr, // Using translation key
                                  "otp_sent".tr, // Using translation key
                                  snackPosition: SnackPosition.TOP,
                                  backgroundColor: Colors.green,
                                  colorText: Colors.white,
                                );
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
                              isLoading = false;
                            });
                            log(e.toString());
                            Get.snackbar(
                              "error".tr, // Using translation key
                              "unknown_error".tr, // Using translation key
                              snackPosition: SnackPosition.TOP,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        style: primaryButtonStyle,
                        child: Text("sign_in".tr), // Using translation key
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}