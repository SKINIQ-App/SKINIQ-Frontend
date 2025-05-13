import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';

class SunscreenGuidePage extends StatefulWidget {
  const SunscreenGuidePage({super.key});

  @override
  State<SunscreenGuidePage> createState() => _SunscreenGuidePageState();
}

class _SunscreenGuidePageState extends State<SunscreenGuidePage> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  late Timer _timer;

  final List<Map<String, dynamic>> slides = [
    {
      "background": "assets/blog/sunscreen_apply.jpg",
      "title": "Why Sunscreen is Essential",
      "subtitle": "☀️ Protect your skin from harmful UV rays that can cause premature aging.",
      "tips": [
        "✅ Apply sunscreen every 2 hours during daylight.",
        "✅ Look for SPF 30+ for daily protection.",
        "🚫 Don't skip sunscreen, even on cloudy days."
      ]
    },
    {
      "background": "assets/blog/spf_guide.jpg",
      "title": "Choosing the Right SPF",
      "subtitle": "🎯 SPF is your skin's best defense against UV radiation.",
      "tips": [
        "✅ Use SPF 50+ for extended outdoor exposure.",
        "✅ Reapply sunscreen every 2 hours.",
        "🚫 Avoid using expired sunscreen."
      ]
    },
    {
      "background": "assets/blog/sunscreen_types.jpg",
      "title": "Types of Sunscreens",
      "subtitle": "🌞 Physical vs. Chemical sunscreens: Which one is right for you?",
      "tips": [
        "✅ Choose physical sunscreens for sensitive skin.",
        "✅ Opt for chemical sunscreens if you're active outdoors.",
        "🚫 Don't mix sunscreen with other skin care products."
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
      backgroundColor: const Color(0xFFFFFAF0),
      appBar: AppBar(
        title: const Text(
          "Sunscreen Guide",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
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
            'assets/blog/sunscreen_protect.jpg',
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
          "🧴 Sunscreen is your skin’s armor. Whether it’s sunny or cloudy, let’s understand how to shield your skin every day!",
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
                      // ignore: deprecated_member_use
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
        activeDotColor: Colors.orange,
        dotColor: Colors.orangeAccent,
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
          "✅ Sunscreen isn’t just for summer — it’s a daily habit that saves your skin for a lifetime. Be consistent, be protected!",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildCTAButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      icon: const Icon(Icons.wb_sunny, color: Colors.white),
      label: const Text(
        "Explore Sunscreen Tips",
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
