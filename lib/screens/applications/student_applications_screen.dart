import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/application_service.dart';
import '../../models/application_model.dart';
import '../../core/app_colors.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/empty_state.dart';

class StudentApplicationsScreen extends StatelessWidget {
  const StudentApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;
    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text("My Applications")),
      body: StreamBuilder<List<ApplicationModel>>(
        stream: ApplicationService().watchStudentApplications(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final apps = snapshot.data!;
          if (apps.isEmpty) {
            return const EmptyState(
              icon: Icons.assignment_outlined,
              title: "No applications yet",
              message: "Apply to opportunities from the Discover tab to track them here.",
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: apps.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final app = apps[index];
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(
                    app.opportunityTitle.isNotEmpty ? app.opportunityTitle : 'Opportunity',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "Applied ${_formatDate(app.appliedAt)}",
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                  trailing: StatusBadge.applicationStatus(app.status),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return "${months[d.month - 1]} ${d.day}, ${d.year}";
  }
}
