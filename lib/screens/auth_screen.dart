import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reflect/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _showEmailForm = false;
  bool _isSignUpMode = true;

  Future<void> _withOAuth(OAuthProvider provider) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithOAuth(provider);
    } catch (e) {
      setState(() => _error = 'Something went wrong. Try again. $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _emailAuth({required bool isSignUp}) async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = Supabase.instance.client;
      if (isSignUp) {
        await client.auth.signUp(
          password: _password.text.trim(),
          email: _email.text.trim(),
        );
      } else {
        await client.auth.signInWithPassword(
          password: _password.text.trim(),
          email: _email.text.trim(),
        );
      }
    } catch (e) {
      setState(() => _error = 'Check your creds and try again. $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 3),
              Text(
                "Reflect",
                style: GoogleFonts.instrumentSerif(
                  fontSize: 56,
                  color: AppColors.ink,
                  height: 1,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'A quiet place to notice\nhow you spend your time.',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 4),
              if (!_showEmailForm) ...[
                _AuthOptionButton(
                  label: 'Continue with Apple',
                  iconAsset: 'assets/icons/apple_logo.svg',
                  onTap: _loading
                      ? null
                      : () => _withOAuth(OAuthProvider.apple),
                ),
                const SizedBox(height: 12),
                _AuthOptionButton(
                  label: 'Continue with Google',
                  iconAsset: 'assets/icons/google_logo.svg',
                  onTap: _loading
                      ? null
                      : () => _withOAuth(OAuthProvider.google),
                ),

                // const SizedBox(height: 24),
                // Center(
                //   child: TextButton(
                //     onPressed: _loading
                //         ? null
                //         : () => setState(() => _showEmailForm = true),
                //     style: TextButton.styleFrom(padding: EdgeInsets.zero),
                //     child: Text(
                //       'Continue with email',
                //       style: GoogleFonts.poppins(
                //         fontSize: 13,
                //         fontWeight: FontWeight.w500,
                //         color: AppColors.ink,
                //         decoration: TextDecoration.underline,
                //         decorationColor: AppColors.ink,
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 12),
                _AuthOptionButton(
                  label: 'Continue with Email',
                  iconAsset: 'assets/icons/email.svg',
                  onTap: _loading
                      ? null
                      : () => setState(() => _showEmailForm = true),
                ),
              ] else ...[
                Row(
                  children: [
                    GestureDetector(
                      onTap: _loading
                          ? null
                          : () => setState(() => _showEmailForm = false),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _CustomTextField(controller: _email, hint: 'Email'),
                const SizedBox(height: 10),
                _CustomTextField(
                  controller: _password,
                  hint: 'Password',
                  obscure: true,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: _AuthOptionButton(
                    label: _loading
                        ? 'Please wait'
                        : (_isSignUpMode ? 'Continue' : 'Sign in'),
                    filled: true,
                    onTap: _loading
                        ? null
                        : () => _emailAuth(isSignUp: _isSignUpMode),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() => _isSignUpMode = !_isSignUpMode),
                    child: Text(
                      _isSignUpMode
                          ? 'Already have an account? Sign in'
                          : "Don't have an account? Sign uo",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ],

              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.redAccent,
                  ),
                ),
              ],
              // const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthOptionButton extends StatelessWidget {
  final String label;
  final String? iconAsset;
  final bool filled;
  final VoidCallback? onTap;

  const _AuthOptionButton({
    super.key,
    required this.label,
    this.iconAsset,
    this.filled = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.ink : AppColors.fill,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconAsset != null) ...[
                SvgPicture.asset(iconAsset!, width: 18, height: 18),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: filled ? AppColors.paper : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  const _CustomTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fill,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: GoogleFonts.poppins(fontSize: 14, color: AppColors.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.muted),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
