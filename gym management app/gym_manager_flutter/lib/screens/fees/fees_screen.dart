// lib/screens/fees/fees_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../../models/member.dart';

class FeesScreen extends StatefulWidget {
  const FeesScreen({super.key});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final fmt = NumberFormat('#,##0', 'en_IN');
    final dateFmt = DateFormat('d MMM yyyy');

    final withDue = state.members.where((m) => m.amountDue > 0).toList();
    final allPayments = <_FlatPayment>[];
    for (final m in state.members) {
      for (final p in m.payments) {
        allPayments.add(_FlatPayment(member: m, payment: p));
      }
    }
    allPayments.sort((a, b) => b.payment.date.compareTo(a.payment.date));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees & Payments'),
        bottom: TabBar(
          controller: _tab,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Pending Dues'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          // ── Overview ──
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Total Revenue',
                        value: '₹${fmt.format(state.totalRevenue)}',
                        icon: Icons.account_balance_wallet,
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        label: 'This Month',
                        value: '₹${fmt.format(state.monthlyRevenue)}',
                        icon: Icons.calendar_month,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        label: 'Pending Dues',
                        value: '₹${fmt.format(state.totalDue)}',
                        icon: Icons.pending_actions,
                        color: AppTheme.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        label: 'Members w/ Due',
                        value: '${withDue.length}',
                        icon: Icons.people,
                        color: AppTheme.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Recent Payments',
                      style: TextStyle(
                          color: AppTheme.textLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
                const SizedBox(height: 10),
                ...allPayments.take(10).map((fp) => _PaymentTile(
                      fp: fp,
                      dateFmt: dateFmt,
                    )),
              ],
            ),
          ),

          // ── Pending Dues ──
          withDue.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.success, size: 64),
                      SizedBox(height: 12),
                      Text('No pending dues!',
                          style: TextStyle(
                              color: AppTheme.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: withDue.length,
                  itemBuilder: (ctx, i) {
                    final m = withDue[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppTheme.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.error.withOpacity(0.15),
                            child: Text(
                              m.name[0].toUpperCase(),
                              style: const TextStyle(
                                  color: AppTheme.error,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m.name,
                                    style: const TextStyle(
                                        color: AppTheme.textLight,
                                        fontWeight: FontWeight.w600)),
                                Text(m.phone,
                                    style: const TextStyle(
                                        color: AppTheme.textMuted, fontSize: 12)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('₹${m.amountDue.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      color: AppTheme.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const Text('pending',
                                  style: TextStyle(
                                      color: AppTheme.textMuted, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

          // ── History ──
          allPayments.isEmpty
              ? const Center(
                  child: Text('No payments yet',
                      style: TextStyle(color: AppTheme.textMuted)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: allPayments.length,
                  itemBuilder: (ctx, i) => _PaymentTile(
                    fp: allPayments[i],
                    dateFmt: dateFmt,
                  ),
                ),
        ],
      ),
    );
  }
}

class _FlatPayment {
  final Member member;
  final PaymentRecord payment;
  _FlatPayment({required this.member, required this.payment});
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _SummaryCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 18)),
          Text(label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final _FlatPayment fp;
  final DateFormat dateFmt;
  const _PaymentTile({required this.fp, required this.dateFmt});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.payments, color: AppTheme.success, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fp.member.name,
                    style: const TextStyle(
                        color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                Text(
                    '${fp.payment.method} • ${dateFmt.format(fp.payment.date)}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                if (fp.payment.note.isNotEmpty)
                  Text(fp.payment.note,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Text('₹${fp.payment.amount.toStringAsFixed(0)}',
              style: const TextStyle(
                  color: AppTheme.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 15)),
        ],
      ),
    );
  }
}
