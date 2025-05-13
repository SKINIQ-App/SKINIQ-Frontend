// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:meditation/screen/login/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/img/On_Boarding_images/Upload Image.jpg",
      "background": "assets/img/Background1.png",
      "title": "Analyze Your Skin Type",
      "subtitle": "📸 Snap a selfie to detect your skin type"
    },
    {
      "image": "assets/img/On_Boarding_images/Skin Description.jpg",
      "background": "assets/img/Background1.png",
      "title": "Tell Us Your Skin Concerns",
      "subtitle": "📝Your skin is unique! Share your concerns—for a tailored approach."
    },
    {
      "image": "assets/img/On_Boarding_images/routine.jpg",
      "background": "assets/img/Background1.png",
      "title": "Get Your Personalized Skincare Routine",
      "subtitle": "🌿 Receive a skincare plan made just for you—simple, effective, and hassle-free!"
    }
  ];

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) => Stack(
              children: [
                Image.asset(
                  onboardingData[index]["background"]!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                    child: Image.asset(
                      onboardingData[index]["image"]!,
                      width: MediaQuery.of(context).size.width * 0.7,
                    ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      onboardingData[index]["title"]!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        onboardingData[index]["subtitle"]!,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
              child: const Icon(Icons.fast_forward_rounded, color: Colors.white, size: 30),
            ),
          ),
          Positioned(
            bottom: 40,
            right: 20,
            child: GestureDetector(
              onTap: _nextPage,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.8),
                ),
                child: const Icon(Icons.arrow_forward_ios, color: Colors.black, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
