import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reflect/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

enum _LoadingAction { none, apple, google, email }

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  _LoadingAction _loadingAction = _LoadingAction.none;
  String? _error;
  bool _showEmailForm = false;
  bool _isSignUpMode = true;

  bool get _loading => _loadingAction != _LoadingAction.none;

  Future<void> _withOAuth(OAuthProvider provider, _LoadingAction action) async {
    setState(() {
      _loadingAction = action;
      _error = null;
    });
    try {
      final authResponse = await Supabase.instance.client.auth
          .getOAuthSignInUrl(
            provider: provider,
            redirectTo: 'io.supabase.reflect://login-callback',
          );

      final result = await FlutterWebAuth2.authenticate(
        url: authResponse.url,
        callbackUrlScheme: 'io.supabase.reflect',
      );

      await Supabase.instance.client.auth.getSessionFromUrl(Uri.parse(result));
    } catch (e) {
      setState(() => _error = 'Something went wrong. Please try again. $e');
    } finally {
      if (mounted) setState(() => _loadingAction = _LoadingAction.none);
    }
  }

  Future<void> _emailAuth({required bool isSignUp}) async {
    setState(() {
      _loadingAction = _LoadingAction.email;
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
      setState(() => _error = 'Check your email and password and try again.');
    } finally {
      if (mounted) setState(() => _loadingAction = _LoadingAction.none);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
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
              const SizedBox(height: 12),
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
                  loading: _loadingAction == _LoadingAction.apple,
                  onTap: _loading
                      ? null
                      : () => _withOAuth(
                          OAuthProvider.apple,
                          _LoadingAction.apple,
                        ),
                ),
                const SizedBox(height: 12),
                _AuthOptionButton(
                  label: 'Continue with Google',
                  iconAsset: 'assets/icons/google_logo.svg',
                  loading: _loadingAction == _LoadingAction.google,
                  onTap: _loading
                      ? null
                      : () => _withOAuth(
                          OAuthProvider.google,
                          _LoadingAction.google,
                        ),
                ),
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
                    label: _isSignUpMode ? 'Continue' : 'Sign in',
                    filled: true,
                    loading: _loadingAction == _LoadingAction.email,
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
                          : "Don't have an account? Sign up",
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
              const Spacer(flex: 1),
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
  final bool loading;
  final VoidCallback? onTap;

  const _AuthOptionButton({
    required this.label,
    this.iconAsset,
    this.filled = false,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null && !loading ? 0.5 : 1.0,
      child: Material(
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
                if (loading) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: filled ? AppColors.paper : AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 10),
                ] else if (iconAsset != null) ...[
                  SvgPicture.asset(iconAsset!, width: 18, height: 18),
                  const SizedBox(width: 10),
                ],
                Text(
                  loading ? 'Please wait' : label,
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
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  const _CustomTextField({
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
