import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../models/startup_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/startup_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_badge.dart';

/// Startups create this profile to unlock posting opportunities. There's
/// no separate admin-verification step — as soon as the profile is saved,
/// the startup can post.
class StartupProfileScreen extends StatefulWidget {
  const StartupProfileScreen({super.key});

  @override
  State<StartupProfileScreen> createState() => _StartupProfileScreenState();
}

class _StartupProfileScreenState extends State<StartupProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _industryController = TextEditingController();
  final _emailController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _industryController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _prefill(StartupModel? startup) {
    if (_initialized || startup == null) return;
    _nameController.text = startup.name;
    _descController.text = startup.description;
    _industryController.text = startup.industry;
    _emailController.text = startup.contactEmail;
    _initialized = true;
  }

  Future<void> _save(String founderUid) async {
    if (!_formKey.currentState!.validate()) return;
    final startupProvider = context.read<StartupProvider>();

    await startupProvider.saveProfile(StartupModel(
      id: founderUid,
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      industry: _industryController.text.trim(),
      founderUid: founderUid,
      contactEmail: _emailController.text.trim(),
      isVerified: true,
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Startup profile saved"), backgroundColor: AppColors.success),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;
    final startupProvider = context.watch<StartupProvider>();

    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text("Startup Profile")),
      body: StreamBuilder<StartupModel?>(
        stream: startupProvider.watchStartup(uid),
        builder: (context, snapshot) {
          final startup = snapshot.data;
          _prefill(startup);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        StatusBadge(label: 'Active', color: AppColors.success, icon: Icons.check_circle),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Your startup can post opportunities as soon as you save this profile.",
                            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Startup Name', prefixIcon: Icon(Icons.business_outlined)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _industryController,
                    decoration: const InputDecoration(labelText: 'Industry', prefixIcon: Icon(Icons.category_outlined)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Contact Email', prefixIcon: Icon(Icons.alternate_email)),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'About the startup', alignLabelWithHint: true),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: startup == null ? "Create Startup Profile" : "Save Changes",
                    isLoading: startupProvider.isSaving,
                    onPressed: () => _save(uid),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
