import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/app_colors.dart';
import '../../widgets/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final model = authProvider.userModel;

    if (user == null) return const SizedBox.shrink();

    final isStartup = model?.role == 'startup';

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: authProvider.profileLoading || model == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      gradient: AppColors.heroGradient,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      model.fullName.isNotEmpty ? model.fullName[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    model.fullName.isNotEmpty ? model.fullName : 'User',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(model.email, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  Card(
                    child: ListTile(
                      leading: Icon(
                        isStartup ? Icons.rocket_launch_outlined : Icons.school_outlined,
                        color: AppColors.aluBlue,
                      ),
                      title: const Text("Account Role"),
                      subtitle: Text(
                        isStartup ? "You post opportunities as a startup" : "You browse and apply to opportunities",
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Chip(
                        label: Text(isStartup ? 'Startup' : 'Student'),
                        backgroundColor: AppColors.aluBlue.withValues(alpha: 0.08),
                        labelStyle: const TextStyle(color: AppColors.aluBlue, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    label: "Log Out",
                    color: AppColors.danger,
                    onPressed: () => authProvider.logout(),
                  ),
                ],
              ),
            ),
    );
  }
}
