// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:meditation/screen/onboarding/onboarding_screen1.dart';
import 'package:meditation/screen/onboarding/onboarding_screen2.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            "assets/img/Background1.png",
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo with Title and Subtitle
              Column(
                children: [
                  Image.asset(
                    "assets/app_logo/applogo.png",
                    height: 110, // Reduced size further
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "SKINIQ",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    "Your Skin Our Care",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white, // Slightly more visible
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Title
              const Text(
                "What brings you to SKINIQ?",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Subtitle
              const Text(
                "Choose a goal to get your skin better.",
                style: TextStyle(
                  fontSize: 18, // Slightly larger font
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),

              // Selection Options (Vertical Format, Bigger Size)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircularOption(
                    context,
                    "assets/icon/skinDisease.png",
                    "Skin Disease",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  const OnboardingScreen2()),
                      );
                    },
                  ),
                  const SizedBox(height: 60), // Adjusted spacing
                  _buildCircularOption(
                    context,
                    "assets/icon/skinCare.png",
                    "Skin Care",
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>  const OnboardingScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper method to create Circular Selection Options (Increased Size)
  Widget _buildCircularOption(
      BuildContext context, String imagePath, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 150, // Increased size further
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22, // Increased font size further
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
