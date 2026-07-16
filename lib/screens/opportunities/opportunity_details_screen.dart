import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../models/opportunity_model.dart';
import '../../core/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../services/application_service.dart';
import '../../models/application_model.dart';
import '../../widgets/custom_button.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final OpportunityModel opportunity;

  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final studentUid = authProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(title: Text(opportunity.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              opportunity.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            if (opportunity.startupName.isNotEmpty)
              Text(
                opportunity.startupName,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(avatar: const Icon(Icons.category_outlined, size: 16), label: Text(opportunity.category)),
                Chip(avatar: const Icon(Icons.place_outlined, size: 16), label: Text(opportunity.location)),
                if (!opportunity.isOpen)
                  const Chip(
                    avatar: Icon(Icons.lock_outline, size: 16, color: AppColors.danger),
                    label: Text('Closed'),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            const Text("Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(opportunity.description, style: const TextStyle(height: 1.5)),
            const SizedBox(height: 24),
            const Text("Requirements", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              opportunity.requirements.isNotEmpty ? opportunity.requirements : 'Not specified.',
              style: const TextStyle(height: 1.5),
            ),
            const SizedBox(height: 32),
            if (studentUid == null)
              const SizedBox.shrink()
            else if (studentUid == opportunity.startupId)
              const Text(
                "This is your own opportunity posting.",
                style: TextStyle(color: AppColors.textSecondary),
              )
            else
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('applications')
                    .where('opportunityId', isEqualTo: opportunity.id)
                    .where('studentUid', isEqualTo: studentUid)
                    .snapshots(),
                builder: (context, snapshot) {
                  final alreadyApplied = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

                  if (alreadyApplied) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success),
                          SizedBox(width: 10),
                          Text("You've already applied to this opportunity."),
                        ],
                      ),
                    );
                  }

                  return _ApplyButton(
                    opportunity: opportunity,
                    studentUid: studentUid,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ApplyButton extends StatefulWidget {
  final OpportunityModel opportunity;
  final String studentUid;

  const _ApplyButton({required this.opportunity, required this.studentUid});

  @override
  State<_ApplyButton> createState() => _ApplyButtonState();
}

class _ApplyButtonState extends State<_ApplyButton> {
  bool _submitting = false;

  Future<void> _apply() async {
    final authProvider = context.read<AuthProvider>();
    final fullName = authProvider.userModel?.fullName ?? 'Student';

    setState(() => _submitting = true);
    try {
      final app = ApplicationModel(
        id: '',
        opportunityId: widget.opportunity.id,
        opportunityTitle: widget.opportunity.title,
        startupId: widget.opportunity.startupId,
        studentUid: widget.studentUid,
        studentName: fullName,
        status: 'pending',
        appliedAt: DateTime.now(),
      );

      await ApplicationService().submitApplication(app);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Application submitted!"), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Couldn't submit application: $e"), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: widget.opportunity.isOpen ? "Apply Now" : "Applications Closed",
      isLoading: _submitting,
      onPressed: widget.opportunity.isOpen ? _apply : null,
    );
  }
}
