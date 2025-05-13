// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:skiniq/screen/blogs/home_remedies.dart';
import 'package:skiniq/screen/blogs/climate_skin.dart';
import 'package:skiniq/screen/blogs/healthy_diet.dart';
import 'package:skiniq/screen/blogs/sunscreen_guide.dart';
import 'package:skiniq/screen/blogs/stay_hydrated.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "User";

  List<Map<String, String>> blogArr = [
    {
      "image": "assets/img/home_remedies.jpg",
      "title": "Home Remedies",
      "subtitle": "Natural skincare treatments",
    },
    {
      "image": "assets/img/climate_factor.jpeg",
      "title": "Climate & Skin",
      "subtitle": "How weather affects your skin",
    },
    {
      "image": "assets/img/dietary_intake.jpeg",
      "title": "Healthy Diet",
      "subtitle": "Best foods for glowing skin",
    },
    {
      "image": "assets/img/sunscreen_protection.jpg",
      "title": "Sunscreen Guide",
      "subtitle": "How to choose the right SPF",
    },
    {
      "image": "assets/img/hydration.jpg",
      "title": "Stay Hydrated",
      "subtitle": "Importance of drinking water",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/img/Background1.png",
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  Text(
                    "Hi, $userName! Take care of your skin today 😊",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSkinHealthSection(),
                  const SizedBox(height: 20),
                  const Text(
                    "Recommended Blogs",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildScrollableBlogs(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Image.asset(
          "assets/app_logo/applogo.png",
          width: 50,
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "SKINIQ",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Your Skin Our Care",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            )
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSkinHealthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Today's Skincare Focus",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                "Skin Analysis",
                "📷 Upadate your  photo & analyze",
                "assets/img/skin_analysis.jpg",
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _buildFeatureCard(
                "Skin ANalysis",
                " 📝Keep your skin concerns up to date.",
                "assets/img/skin_description.webp",
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildFeatureCard(
          "Skin Care Routine",
          "☀️ Start your day fresh & glowing",
          "assets/img/skincare_routine.webp",
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, String imagePath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Image.asset(imagePath, width: 60),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableBlogs() {
    return Expanded(
      child: GridView.builder(
        scrollDirection: Axis.vertical,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.8,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: blogArr.length,
        itemBuilder: (context, index) {
          var blog = blogArr[index];
          return GestureDetector(
            onTap: () => _navigateToBlog(blog["title"]!, context),
            child: _buildBlogCard(blog),
          );
        },
      ),
    );
  }

  Widget _buildBlogCard(Map<String, String> blog) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(blog["image"]!,
                width: double.infinity, height: 100, fit: BoxFit.cover),
          ),
          const SizedBox(height: 10),
          Text(blog["title"]!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text(blog["subtitle"]!,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  void _navigateToBlog(String title, BuildContext context) {
    switch (title) {
      case "Home Remedies":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HomeRemediesPage()));
        break;
      case "Climate & Skin":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const ClimateSkinPage()));
        break;
      case "Healthy Diet":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const HealthyDietPage()));
        break;
      case "Sunscreen Guide":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const SunscreenGuidePage()));
        break;
      case "Stay Hydrated":
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => const StayHydratedPage()));
        break;
    }
  }
}
