import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/opportunity_model.dart';

class OpportunityCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final VoidCallback onTap;
  final Widget? trailingAction;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.onTap,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      opportunity.startupName.isNotEmpty
                          ? opportunity.startupName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opportunity.title,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (opportunity.startupName.isNotEmpty)
                          Text(
                            opportunity.startupName,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                  if (trailingAction != null) trailingAction!,
                ],
              ),
              const SizedBox(height: 12),
              Text(
                opportunity.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _tag(Icons.category_outlined, opportunity.category),
                  _tag(Icons.place_outlined, opportunity.location),
                  if (!opportunity.isOpen)
                    _tag(Icons.lock_outline, 'Closed', color: AppColors.danger),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(IconData icon, String label, {Color? color}) {
    final c = color ?? AppColors.aluBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: c, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
