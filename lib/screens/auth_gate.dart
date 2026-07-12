import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reflect/main.dart';
import 'package:reflect/screens/auth_screen.dart';
import 'package:reflect/screens/home_screen.dart';
import 'package:reflect/screens/setup_screen.dart';
import 'package:reflect/services/supabase_service.dart';
import 'package:reflect/theme/app_theme.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final _service = SupabaseService();

  String? _resolvedForUserId;
  Future<bool>? _setupFuture;

  Future<bool> _resolve() async {
    await _service.ensureUserRow();
    return _service.isSetupCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;

        if (session == null) {
          _resolvedForUserId = null;
          _setupFuture = null;
          return const AuthScreen();
        }

        final userId = session.user.id;
        if (_resolvedForUserId != userId) {
          _resolvedForUserId = userId;
          _setupFuture = _resolve();
        }

        return FutureBuilder<bool>(
          future: _setupFuture,
          builder: (context, setupSnapshot) {
            if (setupSnapshot.connectionState != ConnectionState.done) {
              return const _GateLoading();
            }
            if (setupSnapshot.hasError) {
              return _GateError(
                onRetry: () => setState(() => _setupFuture = _resolve()),
              );
            }

            final completed = setupSnapshot.data ?? false;

            return completed ? const HomeScreen() : const SetupScreen();
          },
        );
      },
    );
  }
}

class _GateLoading extends StatelessWidget {
  const _GateLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Just a moment',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _GateError extends StatelessWidget {
  final VoidCallback onRetry;

  const _GateError({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Couldn\'t load your account',
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.ink),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Try again',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
