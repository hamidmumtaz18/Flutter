// lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../../models/member.dart';
import '../info/gym_info_screen.dart';
import '../members/member_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final fmt = NumberFormat('#,##0', 'en_IN');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.secondary, AppTheme.card],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.gymInfo.name,
                              style: const TextStyle(
                                color: AppTheme.textLight,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Welcome back, ${state.gymInfo.ownerName}',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const GymInfoScreen()),
                          ),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
                            ),
                            child: const Icon(Icons.settings_outlined,
                                color: AppTheme.primary, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Revenue Row
                Row(
                  children: [
                    Expanded(
                      child: _BigStatCard(
                        label: 'This Month',
                        value: '₹${fmt.format(state.monthlyRevenue)}',
                        icon: Icons.trending_up,
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BigStatCard(
                        label: 'Total Due',
                        value: '₹${fmt.format(state.totalDue)}',
                        icon: Icons.pending_actions,
                        color: AppTheme.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Member stats row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total',
                        value: '${state.totalMembers}',
                        icon: Icons.people,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        label: 'Active',
                        value: '${state.activeMembers}',
                        icon: Icons.check_circle,
                        color: AppTheme.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        label: 'Expired',
                        value: '${state.expiredMembers}',
                        icon: Icons.cancel,
                        color: AppTheme.error,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _StatCard(
                        label: 'Expiring',
                        value: '${state.expiringSoon}',
                        icon: Icons.timer,
                        color: AppTheme.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Expiring soon alert
                if (state.expiringSoon > 0) ...[
                  _AlertBanner(
                    message:
                        '${state.expiringSoon} member${state.expiringSoon > 1 ? 's' : ''} expiring within 7 days!',
                    color: AppTheme.warning,
                    icon: Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: 16),
                ],

                // Recent members
                const Text(
                  'Recent Members',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textLight,
                  ),
                ),
                const SizedBox(height: 10),
                if (state.recentMembers.isEmpty)
                  const _EmptyCard(message: 'No members yet. Add your first member!')
                else
                  ...state.recentMembers.map((m) => _MemberTile(
                        member: m,
                        plan: state.getPlanById(m.planId),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MemberDetailScreen(memberId: m.id)),
                        ),
                      )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _BigStatCard(
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
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(label,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;
  const _AlertBanner(
      {required this.message, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(color: color, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textMuted)),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final Member member;
  final dynamic plan;
  final VoidCallback onTap;
  const _MemberTile({required this.member, required this.plan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final daysLeft = member.expiryDate.difference(DateTime.now()).inDays;
    Color statusColor = AppTheme.success;
    if (member.isExpired) statusColor = AppTheme.error;
    else if (member.isExpiringSoon) statusColor = AppTheme.warning;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.primary.withOpacity(0.2),
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                style: const TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name,
                      style: const TextStyle(
                          color: AppTheme.textLight, fontWeight: FontWeight.w600)),
                  Text(plan?.name ?? 'No Plan',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                member.isExpired ? 'Expired' : '$daysLeft days',
                style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
