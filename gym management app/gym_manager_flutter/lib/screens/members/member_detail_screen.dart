// lib/screens/members/member_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../../models/member.dart';

class MemberDetailScreen extends StatelessWidget {
  final String memberId;
  const MemberDetailScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final member = state.getMemberById(memberId);
    if (member == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Member')),
        body: const Center(child: Text('Member not found')),
      );
    }
    final plan = state.getPlanById(member.planId);
    final daysLeft = member.expiryDate.difference(DateTime.now()).inDays;
    final dateFmt = DateFormat('d MMM yyyy');
    Color statusColor = AppTheme.success;
    String statusText = '$daysLeft days left';
    if (member.isExpired) { statusColor = AppTheme.error; statusText = 'Expired'; }
    else if (member.isExpiringSoon) statusColor = AppTheme.warning;

    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppTheme.error),
            onPressed: () => _confirmDelete(context, state, member),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.primary.withOpacity(0.2),
                    child: Text(
                      member.name[0].toUpperCase(),
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(member.name,
                      style: const TextStyle(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                  Text(member.phone,
                      style: const TextStyle(color: AppTheme.textMuted)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.4)),
                    ),
                    child: Text(statusText,
                        style: TextStyle(
                            color: statusColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Membership Info
            _InfoCard(title: 'Membership', children: [
              _InfoRow('Plan', plan?.name ?? 'N/A'),
              _InfoRow('Joined', dateFmt.format(member.joinDate)),
              _InfoRow('Expires', dateFmt.format(member.expiryDate)),
              _InfoRow('Gender', member.gender),
              _InfoRow('Age', '${member.age} years'),
              if (member.address.isNotEmpty) _InfoRow('Address', member.address),
            ]),
            const SizedBox(height: 12),

            // Payment Info
            _InfoCard(title: 'Payment', children: [
              _InfoRow('Total Paid', '₹${member.amountPaid.toStringAsFixed(0)}',
                  valueColor: AppTheme.success),
              _InfoRow('Amount Due', '₹${member.amountDue.toStringAsFixed(0)}',
                  valueColor: member.amountDue > 0 ? AppTheme.error : AppTheme.success),
            ]),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.payments),
                    label: const Text('Add Payment'),
                    onPressed: () => _showPaymentDialog(context, state, member),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.refresh, color: AppTheme.primary),
                    label: const Text('Renew',
                        style: TextStyle(color: AppTheme.primary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _showRenewDialog(context, state, member),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Payment history
            if (member.payments.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Payment History',
                    style: TextStyle(
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
              const SizedBox(height: 8),
              ...member.payments.reversed.map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.payment, color: AppTheme.success, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('₹${p.amount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: AppTheme.success,
                                      fontWeight: FontWeight.bold)),
                              Text('${p.method} • ${dateFmt.format(p.date)}',
                                  style: const TextStyle(
                                      color: AppTheme.textMuted, fontSize: 12)),
                              if (p.note.isNotEmpty)
                                Text(p.note,
                                    style: const TextStyle(
                                        color: AppTheme.textMuted, fontSize: 11)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState state, Member member) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        title: const Text('Delete Member', style: TextStyle(color: AppTheme.textLight)),
        content: Text('Remove ${member.name} permanently?',
            style: const TextStyle(color: AppTheme.textMuted)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await state.deleteMember(member.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, AppState state, Member member) {
    final amtCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String method = 'Cash';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppTheme.card,
          title: const Text('Add Payment', style: TextStyle(color: AppTheme.textLight)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amtCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppTheme.textLight),
                decoration: const InputDecoration(
                    labelText: 'Amount (₹)', prefixIcon: Icon(Icons.currency_rupee)),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: method,
                dropdownColor: AppTheme.surface,
                decoration: const InputDecoration(labelText: 'Method'),
                items: ['Cash', 'UPI', 'Card', 'Bank Transfer']
                    .map((m) => DropdownMenuItem(
                        value: m,
                        child: Text(m, style: const TextStyle(color: AppTheme.textLight))))
                    .toList(),
                onChanged: (v) => setS(() => method = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                style: const TextStyle(color: AppTheme.textLight),
                decoration: const InputDecoration(labelText: 'Note (optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amt = double.tryParse(amtCtrl.text) ?? 0;
                if (amt <= 0) return;
                final payment = PaymentRecord(
                  id: state.generatePaymentId(),
                  amount: amt,
                  date: DateTime.now(),
                  method: method,
                  note: noteCtrl.text.trim(),
                );
                await state.addPayment(member.id, payment);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showRenewDialog(BuildContext context, AppState state, Member member) {
    String planId = member.planId;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppTheme.card,
          title: const Text('Renew Membership',
              style: TextStyle(color: AppTheme.textLight)),
          content: DropdownButtonFormField<String>(
            value: planId,
            dropdownColor: AppTheme.surface,
            decoration: const InputDecoration(labelText: 'Select Plan'),
            items: state.plans
                .where((p) => p.isActive)
                .map((p) => DropdownMenuItem(
                      value: p.id,
                      child: Text('${p.name} — ₹${p.price.toStringAsFixed(0)}',
                          style: const TextStyle(color: AppTheme.textLight)),
                    ))
                .toList(),
            onChanged: (v) => setS(() => planId = v!),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                await state.renewMember(member.id, planId);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Renew'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final Color? valueColor;
  const _InfoRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? AppTheme.textLight,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
