import 'package:flutter/material.dart';
import 'package:skiniq/common/color_extension.dart';
import 'package:skiniq/common_widget/round_button.dart';
import 'package:skiniq/common_widget/round_text_field.dart';
import 'package:skiniq/screen/image_text_user/upload_selfie_screen1.dart';
import 'package:skiniq/services/auth_service.dart';

class OTPVerificationPage extends StatefulWidget {
  final String email;
  final String username; // Add username parameter
  const OTPVerificationPage({super.key, required this.email, required this.username});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  late TextEditingController _otpController;
  bool isResending = false;

  @override
  void initState() {
    _otpController = TextEditingController();
    super.initState();
  }

  void _verifyOTP() async {
    final otp = _otpController.text;
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the OTP")),
      );
      return;
    }
    try {
      await AuthService.verifyEmail(widget.email, otp);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ OTP verified for ${widget.email}")),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UploadSelfieScreen1(username: widget.username), // Pass username
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Verification failed: ${e.toString().replaceAll('Exception: ', '')}")),
        );
      }
    }
  }

  void _resendOTP() async {
    setState(() { isResending = true; });
    try {
      await AuthService.sendOTP(widget.email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("✅ OTP resent to ${widget.email}")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Failed to resend OTP: ${e.toString().replaceAll('Exception: ', '')}")),
        );
      }
    }
    setState(() { isResending = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/img/Background1.png",
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/app_logo/applogo.png",
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "SKINIQ",
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "OTP Verification",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 35),
                  RoundTextField(
                    hintText: "Enter OTP",
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 25),
                  RoundButton(
                    title: "Verify OTP",
                    onPressed: _verifyOTP,
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: isResending ? null : _resendOTP,
                    child: Text(
                      isResending ? "Resending..." : "Resend OTP",
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}