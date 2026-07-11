// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:reflect/theme/app_theme.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;
//   late final Animation<double> _logoOpacity;
//   late final Animation<double> _logoScale;
//   late final Animation<double> _textOpacity;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1600),
//     );

//     _logoOpacity = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
//     );

//     _logoScale = Tween<double>(begin: 0.94, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
//       ),
//     );

//     _textOpacity = CurvedAnimation(
//       parent: _controller,
//       curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
//     );

//     _controller.forward();
//     _decideNextRoute();
//   }

//   Future<void> _decideNextRoute() async {
//     await Future.delayed(const Duration(milliseconds: 900));

//     // will do actual login here shortly..
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.paper,
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             AnimatedBuilder(
//               animation: _controller,
//               builder: (context, child) {
//                 return Opacity(
//                   opacity: _logoOpacity.value,
//                   child: Transform.scale(scale: _logoScale.value, child: child),
//                 );
//               },
//               child: Image.asset(
//                 'assets/images/logo_black.png',
//                 width: 88,
//                 height: 88,
//               ),
//             ),
//             const SizedBox(height: 16),
//             AnimatedBuilder(
//               animation: _controller,
//               builder: (context, child) {
//                 return Opacity(opacity: _textOpacity.value, child: child);
//               },
//               child: Text(
//                 'Reflect',
//                 style: GoogleFonts.instrumentSerif(
//                   fontSize: 32,
//                   color: AppColors.ink,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
