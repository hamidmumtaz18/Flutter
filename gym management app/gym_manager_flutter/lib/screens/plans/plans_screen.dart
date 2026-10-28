// lib/screens/plans/plans_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../../models/plan.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Membership Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppTheme.primary),
            onPressed: () => _showPlanDialog(context, state, null),
          ),
        ],
      ),
      body: state.plans.isEmpty
          ? const Center(
              child: Text('No plans yet. Add one!',
                  style: TextStyle(color: AppTheme.textMuted)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.plans.length,
              itemBuilder: (ctx, i) {
                final plan = state.plans[i];
                final memberCount =
                    state.members.where((m) => m.planId == plan.id).length;
                final color = _hexToColor(plan.color);
                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(18)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child:
                                  Icon(Icons.card_membership, color: color, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(plan.name,
                                      style: const TextStyle(
                                          color: AppTheme.textLight,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(plan.durationLabel,
                                      style: TextStyle(color: color, fontSize: 12)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('₹${plan.price.toStringAsFixed(0)}',
                                    style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20)),
                                Text('$memberCount members',
                                    style: const TextStyle(
                                        color: AppTheme.textMuted, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (plan.description.isNotEmpty) ...[
                              Text(plan.description,
                                  style: const TextStyle(
                                      color: AppTheme.textMuted, fontSize: 13)),
                              const SizedBox(height: 10),
                            ],
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: plan.features
                                  .map((f) => Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(f,
                                            style: TextStyle(
                                                color: color, fontSize: 11)),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text('Edit'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: color,
                                      side: BorderSide(color: color.withOpacity(0.5)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () =>
                                        _showPlanDialog(context, state, plan),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.delete_outline, size: 16),
                                    label: const Text('Delete'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppTheme.error,
                                      side: BorderSide(
                                          color: AppTheme.error.withOpacity(0.5)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () =>
                                        _confirmDelete(context, state, plan),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => _showPlanDialog(context, state, null),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  void _confirmDelete(BuildContext context, AppState state, Plan plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Delete Plan', style: TextStyle(color: AppTheme.textLight)),
        content: Text('Delete "${plan.name}" plan?',
            style: const TextStyle(color: AppTheme.textMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await state.deletePlan(plan.id);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  void _showPlanDialog(BuildContext context, AppState state, Plan? existing) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final priceCtrl =
        TextEditingController(text: existing?.price.toStringAsFixed(0) ?? '');
    final daysCtrl =
        TextEditingController(text: '${existing?.durationDays ?? 30}');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    final featureCtrl = TextEditingController(
        text: existing?.features.join(', ') ?? '');
    String selectedColor = existing?.color ?? '#FF6B35';

    final colors = [
      '#4CAF50', '#2196F3', '#FF9800', '#9C27B0',
      '#F44336', '#FF6B35', '#00BCD4', '#E91E63'
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppTheme.card,
          title: Text(existing == null ? 'New Plan' : 'Edit Plan',
              style: const TextStyle(color: AppTheme.textLight)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dialogField(nameCtrl, 'Plan Name'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _dialogField(priceCtrl, 'Price (₹)',
                        keyboardType: TextInputType.number)),
                    const SizedBox(width: 8),
                    Expanded(child: _dialogField(daysCtrl, 'Days',
                        keyboardType: TextInputType.number)),
                  ],
                ),
                const SizedBox(height: 10),
                _dialogField(descCtrl, 'Description'),
                const SizedBox(height: 10),
                _dialogField(featureCtrl, 'Features (comma separated)'),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Color',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: colors.map((c) {
                    final col = Color(int.parse(c.replaceFirst('#', '0xFF')));
                    return GestureDetector(
                      onTap: () => setS(() => selectedColor = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: col,
                          shape: BoxShape.circle,
                          border: selectedColor == c
                              ? Border.all(color: Colors.white, width: 2.5)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final plan = Plan(
                  id: existing?.id ?? const Uuid().v4(),
                  name: nameCtrl.text.trim(),
                  price: double.tryParse(priceCtrl.text) ?? 0,
                  durationDays: int.tryParse(daysCtrl.text) ?? 30,
                  description: descCtrl.text.trim(),
                  features: featureCtrl.text
                      .split(',')
                      .map((f) => f.trim())
                      .where((f) => f.isNotEmpty)
                      .toList(),
                  color: selectedColor,
                );
                if (existing == null) {
                  await state.addPlan(plan);
                } else {
                  await state.updatePlan(plan);
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: Text(existing == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String label,
      {TextInputType keyboardType = TextInputType.text}) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppTheme.textLight),
        decoration: InputDecoration(labelText: label),
      );
}
