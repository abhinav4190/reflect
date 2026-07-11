import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reflect/screens/auth_screen.dart';
import 'package:reflect/screens/onboarding_screen.dart';
import 'package:reflect/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _treeOpacity;
  late final Animation<double> _treeScale;
  late final Animation<double> _reflectionOpacity;
  late final Animation<double> _reflectionScaleY;
  late final Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _treeOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    _treeScale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );

    _reflectionOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.30, 0.80, curve: Curves.easeIn),
    );

    _reflectionScaleY = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.80, curve: Curves.easeInOutCubic),
      ),
    );

    _textOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    _controller.forward();
    _decideNextRoute();
  }

  Future<void> _decideNextRoute() async {
    await Future.delayed(const Duration(milliseconds: 3100));

    if(!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onbaordingSeen = prefs.getBool('onboarding_seen') ?? false;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_)=> onbaordingSeen ? const AuthScreen() : const OnboardingScreen())
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _treeOpacity.value,
                  child: Transform.scale(scale: _treeScale.value, child: child),
                );
              },
              child: Image.asset('assets/images/tree_top.png', width: 100),
            ),

            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _reflectionOpacity.value,
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: _reflectionScaleY.value,
                    child: child,
                  ),
                );
              },
              child: Image.asset(
                'assets/images/tree_reflection.png',
                width: 100,
              ),
            ),

            const SizedBox(height: 16),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(opacity: _textOpacity.value, child: child);
              },
              child: Text(
                'Reflect',
                style: GoogleFonts.instrumentSerif(
                  fontSize: 35,
                  color: AppColors.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
