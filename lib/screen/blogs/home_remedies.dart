import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';

class HomeRemediesPage extends StatefulWidget {
  const HomeRemediesPage({super.key});

  @override
  State<HomeRemediesPage> createState() => _HomeRemediesPageState();
}

class _HomeRemediesPageState extends State<HomeRemediesPage> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  late Timer _timer;

  final List<Map<String, dynamic>> slides = [
    {
      "background": "assets/blog/aloevera.jpg",
      "title": "Aloe Vera Magic",
      "subtitle": "🌿 Aloe vera soothes skin inflammation and hydrates deeply.",
      "tips": [
        "✅ Apply fresh aloe vera gel to the skin for 20 minutes.",
        "✅ Use aloe vera in face masks for added moisture.",
        "🚫 Avoid using products with added chemicals."
      ]
    },
    {
      "background": "assets/blog/honey.jpeg",
      "title": "Honey Glow",
      "subtitle": "🍯 Honey is a natural humectant that draws moisture to the skin.",
      "tips": [
        "✅ Use raw honey as a face mask.",
        "✅ Combine with cinnamon for acne-prone skin.",
        "🚫 Avoid sugary processed honey."
      ]
    },
    {
      "background": "assets/blog/tea_tree.jpg",
      "title": "Tea Tree Oil Treatment",
      "subtitle": "🌱 Tea tree oil fights acne-causing bacteria.",
      "tips": [
        "✅ Dilute tea tree oil with carrier oil and apply to acne.",
        "✅ Use as a spot treatment overnight.",
        "🚫 Avoid using it undiluted as it can irritate."
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
        title: const Text("Home Remedies for Skin", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
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
            'assets/blog/remedies_cover.png', // You can change this image to anything relevant
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
          "🌿 Nature has healing powers! These simple home remedies can do wonders for your skin — without harsh chemicals.",
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
              margin: const EdgeInsets.symmetric(horizontal: 12),
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
                    const SizedBox(height: 12),
                    ...slide["tips"].map<Widget>((tip) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          tip,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
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
        activeDotColor: Colors.green,
        dotColor: Colors.greenAccent,
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
          "✅ Choose gentle, natural remedies. Your skin deserves safe care that heals from within.",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildCTAButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      icon: const Icon(Icons.spa, color: Colors.white),
      label: const Text(
        "Explore Natural Skincare",
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
