import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../providers/opportunity_provider.dart';
import '../../models/opportunity_model.dart';
import '../../models/startup_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/empty_state.dart';
import 'startup_profile_gate.dart';

const _categories = ['Software Development', 'Design', 'Marketing', 'Operations', 'Research', 'Business Analysis', 'Content Creation', 'Community Management', 'General'];

class PostOpportunityScreen extends StatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _locationController = TextEditingController(text: 'Remote');
  String _category = _categories.first;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _requirementsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit(StartupModel startup) async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<OpportunityProvider>();
    final user = context.read<AuthProvider>().user;

    final newOp = OpportunityModel(
      id: '',
      startupId: user!.uid,
      startupName: startup.name,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      requirements: _requirementsController.text.trim(),
      category: _category,
      location: _locationController.text.trim().isEmpty ? 'Remote' : _locationController.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await provider.addOpportunity(newOp);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Opportunity posted!"), backgroundColor: AppColors.success),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Couldn't post opportunity: $e"), backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Internship")),
      // Only a verified startup profile can post — this is the flow that
      // used to be hardcoded/ungated. StartupProfileGate wires in the real
      // Firestore-backed verification status.
      body: StartupProfileGate(
        builder: (startup) {
          final provider = context.watch<OpportunityProvider>();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Frontend Developer Intern'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _category = v!),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location', hintText: 'e.g. Kigali / Remote'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descController,
                    maxLines: 4,
                    decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _requirementsController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Requirements',
                      hintText: 'e.g. Basic Flutter knowledge, 3rd year+',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    label: "Post Opportunity",
                    isLoading: provider.isLoading,
                    onPressed: () => _submit(startup),
                  ),
                ],
              ),
            ),
          );
        },
        lockedBuilder: () => const EmptyState(
          icon: Icons.verified_outlined,
          title: "Verification required",
          message: "Complete and get your startup profile verified before posting opportunities.",
        ),
      ),
    );
  }
}
