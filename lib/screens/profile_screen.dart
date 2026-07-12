import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reflect/main.dart';
import 'package:reflect/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        surfaceTintColor: AppColors.paper,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.instrumentSerif(
            fontSize: 22,
            color: AppColors.ink,
          ),
        ),
      ),
      body: Padding(padding: EdgeInsets.all(24), child: Align(
        alignment: Alignment.bottomLeft,
        child: TextButton(onPressed: ()=> supabase.auth.signOut(), child: Text('Sign out', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted),)),
      ),),
    );
  }
}
