import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../core/app_colors.dart';
import '../../models/opportunity_model.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/status_badge.dart';
import '../opportunities/post_opportunity_screen.dart';

class StartupDashboardScreen extends StatelessWidget {
  const StartupDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;
    final opportunityProvider = context.read<OpportunityProvider>();

    if (uid == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text("Startup Dashboard")),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.aluGold,
        foregroundColor: AppColors.aluBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostOpportunityScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Post Role"),
      ),
      body: StreamBuilder<List<OpportunityModel>>(
        stream: opportunityProvider.opportunitiesForStartup(uid),
        builder: (context, oppSnapshot) {
          if (!oppSnapshot.hasData) return const Center(child: CircularProgressIndicator());

          final opportunities = oppSnapshot.data!
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (opportunities.isEmpty) {
            return const EmptyState(
              icon: Icons.post_add,
              title: "No opportunities posted yet",
              message: "Tap \"Post Role\" to publish your first internship listing.",
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
            itemCount: opportunities.length,
            itemBuilder: (context, index) {
              final opp = opportunities[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ExpansionTile(
                  title: Text(opp.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Row(
                    children: [
                      Icon(
                        opp.isOpen ? Icons.check_circle_outline : Icons.pause_circle_outline,
                        size: 14,
                        color: opp.isOpen ? AppColors.success : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(opp.isOpen ? "Open" : "Closed", style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'toggle') {
                        opportunityProvider.setOpportunityOpen(opp.id, !opp.isOpen);
                      } else if (value == 'delete') {
                        opportunityProvider.deleteOpportunity(opp.id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'toggle', child: Text(opp.isOpen ? 'Close listing' : 'Reopen listing')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
                    ],
                  ),
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('applications')
                          .where('opportunityId', isEqualTo: opp.id)
                          .snapshots(),
                      builder: (context, appSnapshot) {
                        if (!appSnapshot.hasData) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          );
                        }
                        final apps = appSnapshot.data!.docs;
                        if (apps.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text("No applicants yet.", style: TextStyle(color: AppColors.textSecondary)),
                          );
                        }
                        return Column(
                          children: apps.map((app) {
                            final status = app['status'] ?? 'pending';
                            return ListTile(
                              title: Text(app['studentName'] ?? 'Student'),
                              subtitle: StatusBadge.applicationStatus(status),
                              trailing: status == 'pending'
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.check, color: AppColors.success),
                                          tooltip: 'Accept',
                                          onPressed: () => app.reference.update({'status': 'accepted'}),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, color: AppColors.danger),
                                          tooltip: 'Reject',
                                          onPressed: () => app.reference.update({'status': 'rejected'}),
                                        ),
                                      ],
                                    )
                                  : null,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
