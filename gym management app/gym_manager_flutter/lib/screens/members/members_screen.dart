// lib/screens/members/members_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../../models/member.dart';
import 'add_member_screen.dart';
import 'member_detail_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _searchCtrl = TextEditingController();
  String _filter = 'All'; // All, Active, Expired, Expiring
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    List<Member> members = state.searchMembers(_query);

    if (_filter == 'Active') members = members.where((m) => !m.isExpired).toList();
    if (_filter == 'Expired') members = members.where((m) => m.isExpired).toList();
    if (_filter == 'Expiring') members = members.where((m) => m.isExpiringSoon).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: AppTheme.primary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddMemberScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Search by name, phone or email...',
                prefixIcon: Icon(Icons.search, color: AppTheme.textMuted),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['All', 'Active', 'Expired', 'Expiring'].map((f) {
                final isSelected = _filter == f;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : AppTheme.card,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      f,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textMuted,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: members.isEmpty
                ? const Center(
                    child: Text('No members found',
                        style: TextStyle(color: AppTheme.textMuted)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: members.length,
                    itemBuilder: (ctx, i) {
                      final m = members[i];
                      final plan = state.getPlanById(m.planId);
                      final daysLeft =
                          m.expiryDate.difference(DateTime.now()).inDays;
                      Color statusColor = AppTheme.success;
                      if (m.isExpired) statusColor = AppTheme.error;
                      else if (m.isExpiringSoon) statusColor = AppTheme.warning;

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MemberDetailScreen(memberId: m.id)),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: statusColor.withOpacity(0.2), width: 1),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppTheme.primary.withOpacity(0.2),
                                child: Text(
                                  m.name.isNotEmpty ? m.name[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m.name,
                                        style: const TextStyle(
                                            color: AppTheme.textLight,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15)),
                                    const SizedBox(height: 2),
                                    Text(m.phone,
                                        style: const TextStyle(
                                            color: AppTheme.textMuted, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            plan?.name ?? 'No Plan',
                                            style: const TextStyle(
                                                color: AppTheme.primary,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      m.isExpired ? 'Expired' : '$daysLeft d left',
                                      style: TextStyle(
                                          color: statusColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  if (m.amountDue > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '₹${m.amountDue.toStringAsFixed(0)} due',
                                        style: const TextStyle(
                                            color: AppTheme.error,
                                            fontSize: 11),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddMemberScreen()),
        ),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }
}
