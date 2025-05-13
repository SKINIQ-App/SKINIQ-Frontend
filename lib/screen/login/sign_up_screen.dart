import 'package:flutter/material.dart';
import 'package:skiniq/common/color_extension.dart';
import 'package:skiniq/common_widget/round_button.dart';
import 'package:skiniq/common_widget/round_text_field.dart';
import 'package:skiniq/screen/login/otp_verification_page.dart';
import 'package:skiniq/screen/login/policy_screen.dart';
import 'package:skiniq/services/auth_service.dart';


class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isTrue = false;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleGetStarted() async {
    if (!isTrue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the Privacy Policy")),
      );
      return;
    }
    try {
      await AuthService.signup(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationPage(
              email: _emailController.text,
              username: _usernameController.text, // Pass username
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup failed: ${e.toString().replaceAll('Exception: ', '')}")),
        );
      }
    }
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
                    "Your Skin Our Care",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 35),
                  MaterialButton(
                    onPressed: () {},
                    minWidth: double.infinity,
                    elevation: 0,
                    color: const Color(0xff8E97FD),
                    height: 55,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 15),
                        Image.asset('assets/img/fb.png', width: 25, height: 25),
                        const Expanded(
                          child: Text(
                            "CONTINUE WITH FACEBOOK",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  MaterialButton(
                    onPressed: () {},
                    minWidth: double.infinity,
                    elevation: 0,
                    color: Colors.white,
                    height: 55,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: TColor.tertiary, width: 1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 15),
                        Image.asset('assets/img/google.png', width: 25, height: 25),
                        Expanded(
                          child: Text(
                            "CONTINUE WITH GOOGLE",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    "OR LOG IN WITH EMAIL",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 30),
                  RoundTextField(hintText: "Username", controller: _usernameController),
                  const SizedBox(height: 15),
                  RoundTextField(hintText: "Email address", controller: _emailController),
                  const SizedBox(height: 15),
                  RoundTextField(hintText: "Password", obscureText: true, controller: _passwordController),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        "I have read the ",
                        style: TextStyle(color: TColor.secondaryText, fontSize: 14),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PolicyScreen()),
                          );
                        },
                        child: Text(
                          "Privacy Policy",
                          style: TextStyle(
                            color: TColor.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            isTrue = !isTrue;
                          });
                        },
                        icon: Icon(
                          isTrue ? Icons.check_box : Icons.check_box_outline_blank_rounded,
                          color: isTrue ? TColor.primary : TColor.secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  RoundButton(
                    title: "GET STARTED",
                    onPressed: _handleGetStarted,
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