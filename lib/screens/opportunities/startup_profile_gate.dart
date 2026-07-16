import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/startup_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/startup_provider.dart';
import '../../widgets/custom_button.dart';
import '../startups/startup_profile_screen.dart';

/// Wraps any child that requires a startup profile to exist (currently:
/// posting opportunities). There's no admin-verification gate — as soon as
/// a startup profile is created, it can post.
class StartupProfileGate extends StatelessWidget {
  final Widget Function(StartupModel startup) builder;
  final Widget Function() lockedBuilder;

  const StartupProfileGate({super.key, required this.builder, required this.lockedBuilder});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;
    final startupProvider = context.watch<StartupProvider>();

    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<StartupModel?>(
      stream: startupProvider.watchStartup(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final startup = snapshot.data;

        if (startup == null) {
          return _CallToAction(
            title: "Set up your startup profile",
            message: "You'll need a startup profile before you can post opportunities.",
            buttonLabel: "Create Startup Profile",
          );
        }

        return builder(startup);
      },
    );
  }
}

class _CallToAction extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;

  const _CallToAction({required this.title, required this.message, required this.buttonLabel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_outlined, size: 56),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            CustomButton(
              label: buttonLabel,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StartupProfileScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
