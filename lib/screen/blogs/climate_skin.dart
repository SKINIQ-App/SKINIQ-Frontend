// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';

class ClimateSkinPage extends StatefulWidget {
  const ClimateSkinPage({super.key});

  @override
  State<ClimateSkinPage> createState() => _ClimateSkinPageState();
}

class _ClimateSkinPageState extends State<ClimateSkinPage> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  late Timer _timer;

  final List<Map<String, dynamic>> slides = [
    {
      "background": "assets/blog/weather_skin.png",
      "title": "How Weather Affects Your Skin",
      "subtitle":
          "🌦️ Cold, hot, or humid weather deeply influences your skin. Learn to adapt and protect.",
      "tips": [
        "✅ Cold dries your skin — moisturize regularly.",
        "✅ Hot climate increases sweat — cleanse daily.",
        "🚫 Avoid harsh products in extreme weather."
      ]
    },
    {
      "background": "assets/blog/hot_humid.jpg",
      "title": "Hot & Humid Climate",
      "subtitle":
          "🔥 Sweat, sebum & clogged pores! Learn how to stay cool and breakout-free.",
      "tips": [
        "✅ Use gel-based, non-comedogenic moisturizers.",
        "✅ Wash face twice daily with gentle cleanser.",
        "🚫 Skip heavy creams — they trap heat & oil."
      ]
    },
    {
      "background": "assets/blog/dry_desert.jpeg",
      "title": "Dry & Desert Climate",
      "subtitle":
          "🏜️ Low humidity leads to cracked, flaky skin. Deep hydration is key.",
      "tips": [
        "✅ Use thick creams or oils with ceramides.",
        "✅ Apply moisturizer right after shower.",
        "🚫 Avoid over-exfoliation — it worsens dryness."
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < slides.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          "Climate & Skin",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildHeaderImage(),
            const SizedBox(height: 20),
            _buildIntroText(),
            const SizedBox(height: 24),
            _buildSlider(),
            const SizedBox(height: 16),
            _buildIndicator(),
            const SizedBox(height: 24),
            _buildOutro(),
            const SizedBox(height: 24),
            _buildCTAButton(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/blog/sunscreen_protection.jpg',
            width: double.infinity,
            fit: BoxFit.cover,
            height: 180,
          ),
        ),
      ),
    );
  }

  Widget _buildIntroText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FadeIn(
        duration: const Duration(milliseconds: 800),
        child: const Text(
          "🌍 Your skin reacts to climate shifts. From dry winters to humid summers — let’s learn how to care for it the smart way!",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return SizedBox(
      height: 340,
      child: PageView.builder(
        controller: _pageController,
        itemCount: slides.length,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemBuilder: (context, index) {
          final slide = slides[index];
          return FadeIn(
            duration: const Duration(milliseconds: 500),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage(slide["background"]),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slide["title"],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      slide["subtitle"],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(
                      slide["tips"].length,
                      (i) => Text(
                        slide["tips"][i],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndicator() {
    return SmoothPageIndicator(
      controller: _pageController,
      count: slides.length,
      effect: const WormEffect(
        activeDotColor: Colors.teal,
        dotColor: Colors.tealAccent,
        dotHeight: 12,
        dotWidth: 12,
      ),
    );
  }

  Widget _buildOutro() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FadeInUp(
        duration: const Duration(milliseconds: 700),
        child: const Text(
          "✅ Choose climate-friendly skincare. Whether it's freezing, humid, or dry — your skin deserves thoughtful care.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildCTAButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      icon: const Icon(Icons.eco, color: Colors.white),
      label: const Text(
        "Try Personalized Skin Tips",
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Coming soon!")),
        );
      },
    );
  }
}
