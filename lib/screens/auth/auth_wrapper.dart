import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/app_colors.dart';
import '../student/student_shell.dart';
import '../startups/startup_shell.dart';
import 'login_screen.dart';

/// This is the fix for "startups and students land on the same page":
/// once we know the signed-in user AND have resolved their role from
/// Firestore, we branch into two completely different navigation shells.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    if (authProvider.user == null) {
      return const LoginScreen();
    }

    if (authProvider.profileLoading) {
      return const Scaffold(
        backgroundColor: AppColors.aluBlue,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (authProvider.userModel == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
                const SizedBox(height: 16),
                Text(
                  authProvider.profileError ?? "Couldn't load your profile.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => authProvider.logout(),
                  child: const Text("Log Out"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (authProvider.role == 'startup') {
      return const StartupShell();
    }
    return const StudentShell();
  }
}
