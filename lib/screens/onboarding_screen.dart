import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reflect/screens/auth_screen.dart';
import 'package:reflect/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingSlide {
  final String heading;
  final String body;

  const _OnboardingSlide({required this.heading, required this.body});
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _slides = const [
    _OnboardingSlide(
      heading: 'Notice your time',
      body: 'A few words, every hour or so.\nNo forms, no friction.',
    ),
    _OnboardingSlide(
      heading: 'See it add up',
      body: 'Time, money and habits\nquietly organised for you.',
    ),
    _OnboardingSlide(
      heading: 'Stay honest with yourself',
      body: 'Not about perfection. \nJust paying attention',
    ),
  ];

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsetsGeometry.only(right: 24, top: 12),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    "Skip",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: EdgeInsetsGeometry.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slide.heading,
                          style: GoogleFonts.instrumentSerif(
                            fontSize: 40,
                            color: AppColors.ink,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 14,),
                        Text(slide.body,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: AppColors.muted,
                          height: 1.6
                        ),)
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.ink : AppColors.fill,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: Material(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      if (isLastPage) {
                        _finishOnboarding();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                    child: Container(
                      height: 52,
                      alignment: Alignment.center,
                      child: Text(
                        isLastPage ? 'Get Started' : 'Next',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.paper,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32,)
          ],
        ),
      ),
    );
  }
}
