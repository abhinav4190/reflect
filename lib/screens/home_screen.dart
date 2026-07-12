import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reflect/main.dart';
import 'package:reflect/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _name;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final userId = supabase.auth.currentUser!.id;
    final row = await supabase
        .from('users')
        .select('full_name')
        .eq('id', userId)
        .maybeSingle();
    setState(() {
      _name = row?['full_name'] as String?;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Center(
          child: _loading
              ? const CircularProgressIndicator(color: AppColors.ink)
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (_name?.isNotEmpty ?? false)
                          ? 'Welcome, $_name'
                          : 'Welcome',
                      style: GoogleFonts.instrumentSerif(
                        fontSize: 28,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 20,),
                    TextButton(onPressed: ()=> supabase.auth.signOut(), child: Text('Sign out', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted),))
                  ],
                ),
        ),
      ),
    );
  }
}
