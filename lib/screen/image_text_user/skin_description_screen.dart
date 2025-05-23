import 'package:flutter/material.dart';
import 'package:skiniq/screen/main_tabview/main_tabview_screen.dart';
import 'package:skiniq/services/skin_service.dart';

class SkinDescriptionScreen extends StatefulWidget {
  final String username;
  const SkinDescriptionScreen({super.key, required this.username});

  @override
  State<SkinDescriptionScreen> createState() => _SkinDescriptionScreenState();
}

class _SkinDescriptionScreenState extends State<SkinDescriptionScreen> {
  String? gender;
  String? age;
  String? skinType;
  List<String> skinConcerns = [];
  List<String> skinConditionDiseases = [];
  String? skinBreakouts;
  String? skinDescription;
  int currentIndex = 0;
  bool _isLoading = false;

  final List<Map<String, dynamic>> questions = [
    {'question': "What is your gender?", 'options': ["Female", "Male", "Non-Binary", "Prefer not to say"]},
    {'question': "What is your age range?", 'options': ["Under 18", "18-25", "26-35", "36-50", "50+"]},
    {
      'question': "What is your skin type?",
      'options': ["Oily", "Dry", "Normal", "Combination", "Sensitive"],
      'info': "This was predicted from your selfie, but you can change it if needed."
    },
    {
      'question': "Do you have any skin concerns?",
      'options': [
        "Acne",
        "Acne Scars",
        "Age Spots",
        "Black Heads",
        "Dark Circles",
        "Dark Spots",
        "Enlarge Pores",
        "Fine Lines",
        "Hyperpigmentation",
        "Lip Hyperpigmentation",
        "Melasma",
        "Milia",
        "Pimples",
        "Sunburn",
        "Whiteheads",
        "Wrinkles"
      ],
      'multiSelect': true
    },
    {
      'question': "Any Conditions/Diseases you suffer from?",
      'options': ["PCOD/PCOS", "Diabetes", "Inflammation", "Eczema", "None"],
      'multiSelect': true
    },
    {
      'question': "How often do you experience skin breakouts/irritation?",
      'options': ["Never", "Rarely", "Occasionally", "Sometimes", "Often", "Constantly"]
    },
    {'question': "Describe your skin", 'options': [], 'isTextField': true},
  ];

  @override
  void initState() {
    super.initState();
    _fetchPredictedSkinType();
  }

  Future<void> _fetchPredictedSkinType() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userProfile = await SkinService.getUserProfile(widget.username);
      setState(() {
        skinType = userProfile['skin_type'] ?? userProfile['predicted_skin_type'] ?? "Normal";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        skinType = null;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitQuestionnaire() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final skinDetails = {
        'username': widget.username,
        'gender': gender!,
        'age': _parseAge(age!),
        'skinType': skinType!,
        'skinConcerns': skinConcerns,
        'skinConditionDiseases': skinConditionDiseases,
        'skinBreakouts': skinBreakouts!,
        'skinDescription': skinDescription!,
      };
      await SkinService.submitQuestionnaire(skinDetails);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainTabViewScreen(username: widget.username),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit questionnaire: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _parseAge(String ageRange) {
    switch (ageRange) {
      case "Under 18":
        return 16;
      case "18-25":
        return 22;
      case "26-35":
        return 30;
      case "36-50":
        return 40;
      case "50+":
        return 55;
      default:
        return 30;
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
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/app_logo/applogo.png",
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "SKINIQ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.5,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(1, 1),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Your Skin Our Care",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            questions[currentIndex]['question'],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF27AE60),
                            ),
                          ),
                          if (questions[currentIndex]['info'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              questions[currentIndex]['info'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                          const SizedBox(height: 15),
                          if (questions[currentIndex]['options'] != null &&
                              questions[currentIndex]['options'].isNotEmpty)
                            Wrap(
                              spacing: 10.0,
                              runSpacing: 8.0,
                              children: (questions[currentIndex]['options'] as List<String>).map((option) {
                                bool isMultiSelect = questions[currentIndex].containsKey('multiSelect') &&
                                    questions[currentIndex]['multiSelect'] == true;

                                return ChoiceChip(
                                  label: Text(option),
                                  selected: _isOptionSelected(option),
                                  onSelected: (selected) {
                                    setState(() {
                                      _updateSelection(option, isMultiSelect);
                                    });
                                  },
                                  backgroundColor: Colors.grey[200],
                                  selectedColor: const Color.fromARGB(255, 198, 232, 189),
                                  labelStyle: TextStyle(
                                    color: _isOptionSelected(option) ? Colors.white : Colors.black,
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                );
                              }).toList(),
                            ),
                          if (questions[currentIndex]['isTextField'] == true)
                            TextField(
                              onChanged: (value) {
                                setState(() {
                                  skinDescription = value;
                                });
                              },
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: "Describe your skin here...",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                contentPadding: const EdgeInsets.all(12),
                              ),
                              style: const TextStyle(fontSize: 16),
                            ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    if (_isQuestionAnswered()) {
                                      if (currentIndex < questions.length - 1) {
                                        setState(() {
                                          currentIndex++;
                                        });
                                      } else {
                                        await _submitQuestionnaire();
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("Please answer the question!")),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                              backgroundColor: const Color.fromARGB(255, 198, 232, 189),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    currentIndex == questions.length - 1 ? "SUBMIT" : "NEXT",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isQuestionAnswered() {
    if (questions[currentIndex].containsKey('isTextField') && questions[currentIndex]['isTextField'] == true) {
      return skinDescription != null && skinDescription!.isNotEmpty;
    }

    if (currentIndex == 3) {
      return skinConcerns.isNotEmpty;
    }

    if (currentIndex == 4) {
      return skinConditionDiseases.isNotEmpty;
    }

    return gender != null || age != null || skinType != null || skinBreakouts != null;
  }

  bool _isOptionSelected(String option) {
    return (currentIndex == 3 && skinConcerns.contains(option)) ||
        (currentIndex == 4 && skinConditionDiseases.contains(option)) ||
        (currentIndex == 0 && gender == option) ||
        (currentIndex == 1 && age == option) ||
        (currentIndex == 2 && skinType == option) ||
        (currentIndex == 5 && skinBreakouts == option);
  }

  void _updateSelection(String option, bool isMultiSelect) {
    if (isMultiSelect && currentIndex == 3) {
      skinConcerns.contains(option) ? skinConcerns.remove(option) : skinConcerns.add(option);
    } else if (isMultiSelect && currentIndex == 4) {
      skinConditionDiseases.contains(option) ? skinConditionDiseases.remove(option) : skinConditionDiseases.add(option);
    } else {
      if (currentIndex == 0) gender = option;
      if (currentIndex == 1) age = option;
      if (currentIndex == 2) skinType = option;
      if (currentIndex == 5) skinBreakouts = option;
    }
  }
}