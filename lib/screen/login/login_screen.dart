// login_screen.dart (complete file with fixes)
import 'package:flutter/material.dart';
import 'package:skiniq/common/color_extension.dart';
import 'package:skiniq/common_widget/round_button.dart';
import 'package:skiniq/common_widget/round_text_field.dart';
import 'package:skiniq/screen/login/forgot_password_screen.dart';
import 'package:skiniq/screen/login/sign_up_screen.dart';
import 'package:skiniq/screen/main_tabview/main_tabview_screen.dart';
import 'package:skiniq/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }
    try {
      await AuthService.login(email, password);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainTabViewScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login failed: ${e.toString().replaceAll('Exception: ', '')}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/img/Background1.png",
              fit: BoxFit.cover,
            ),
          ),

          /// Content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// Logo
                    Image.asset(
                      "assets/app_logo/applogo.png",
                      width: 120,
                      height: 120,
                    ),
                    const SizedBox(height: 20),

                    /// Welcome Text
                    Text(
                      "Welcome Back!",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 25),

                    /// Facebook Login Button
                    MaterialButton(
                      onPressed: () {},
                      minWidth: double.infinity,
                      elevation: 0,
                      color: const Color(0xff8E97FD),
                      height: 60,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/img/fb.png',
                            width: 25,
                            height: 25,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "CONTINUE WITH FACEBOOK",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Google Login Button
                    MaterialButton(
                      onPressed: () {},
                      minWidth: double.infinity,
                      elevation: 0,
                      color: Colors.white,
                      height: 60,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: TColor.tertiary, width: 1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/img/google.png',
                            width: 25,
                            height: 25,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "CONTINUE WITH GOOGLE",
                            style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 35),

                    /// OR LOG IN WITH EMAIL
                    Text(
                      "OR LOG IN WITH EMAIL",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Email & Password Fields
                    RoundTextField(
                      hintText: "Email address",
                      controller: _emailController,
                    ),
                    const SizedBox(height: 20),
                    RoundTextField(
                      hintText: "Password",
                      obscureText: true,
                      controller: _passwordController,
                    ),
                    const SizedBox(height: 20),

                    /// Login Button
                    RoundButton(
                      title: "LOG IN",
                      onPressed: _handleLogin,
                    ),

                    /// Forgot Password
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    /// Sign Up Option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "CREATE A NEW ACCOUNT?",
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SignUpScreen()),
                            );
                          },
                          child: Text(
                            "SIGN UP",
                            style: TextStyle(
                              color: TColor.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}