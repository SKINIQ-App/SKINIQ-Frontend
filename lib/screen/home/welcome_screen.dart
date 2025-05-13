import 'package:flutter/material.dart';
import 'package:skiniq/common_widget/round_button.dart';
import 'package:skiniq/screen/home/selection_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/img/Background1.png",
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Image.asset(
                    "assets/app_logo/applogo.png",
                    width: MediaQuery.of(context).size.width * 0.35,
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "SKINIQ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    "Your Skin Our Care",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              RoundButton(
                title: "GET STARTED",
                type: RoundButtonType.secondary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SelectionScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
