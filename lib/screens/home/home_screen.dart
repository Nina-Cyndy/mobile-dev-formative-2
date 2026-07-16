import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../core/app_colors.dart';
import '../../models/opportunity_model.dart';
import '../../widgets/opportunity_card.dart';
import '../../widgets/empty_state.dart';
import '../opportunities/opportunity_details_screen.dart';

/// The student "Discover" tab. Opportunities are pulled live from Firestore
/// via OpportunityProvider (no hardcoded list); search/category filtering is
/// done client-side over that live stream.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _category = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final opportunityProvider = context.read<OpportunityProvider>();
    final fullName = context.watch<AuthProvider>().userModel?.fullName ?? '';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          fullName.isNotEmpty ? "Hi, ${fullName.split(' ').first} 👋" : "Discover",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Find internships with ALU startups",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v.toLowerCase()),
                    decoration: InputDecoration(
                      hintText: 'Search by title or startup...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<OpportunityModel>>(
                stream: opportunityProvider.allOpportunities(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return EmptyState(
                      icon: Icons.error_outline,
                      title: "Couldn't load opportunities",
                      message: snapshot.error.toString(),
                    );
                  }

                  final all = snapshot.data ?? [];
                  final categories = ['All', ...{for (final o in all) o.category}];

                  var filtered = all.where((o) {
                    final matchesQuery = _query.isEmpty ||
                        o.title.toLowerCase().contains(_query) ||
                        o.startupName.toLowerCase().contains(_query);
                    final matchesCategory = _category == 'All' || o.category == _category;
                    return matchesQuery && matchesCategory;
                  }).toList();

                  return Column(
                    children: [
                      SizedBox(
                        height: 44,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final c = categories[i];
                            final selected = c == _category;
                            return ChoiceChip(
                              label: Text(c),
                              selected: selected,
                              onSelected: (_) => setState(() => _category = c),
                              selectedColor: AppColors.aluBlue,
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : AppColors.textPrimary,
                              ),
                            );
                          },
                        ),
                      ),
                      Expanded(
                        child: all.isEmpty
                            ? const EmptyState(
                                icon: Icons.work_outline,
                                title: "No opportunities yet",
                                message: "Check back soon — startups are posting new roles regularly.",
                              )
                            : filtered.isEmpty
                                ? const EmptyState(
                                    icon: Icons.search_off,
                                    title: "No matches",
                                    message: "Try a different search term or category.",
                                  )
                                : ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                                    itemCount: filtered.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                                    itemBuilder: (context, index) {
                                      final o = filtered[index];
                                      return OpportunityCard(
                                        opportunity: o,
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OpportunityDetailScreen(opportunity: o),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
