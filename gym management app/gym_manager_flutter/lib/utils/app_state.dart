// lib/utils/app_state.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/member.dart';
import '../models/plan.dart';
import '../models/gym_info.dart';
import 'data_store.dart';

class AppState extends ChangeNotifier {
  List<Member> _members = [];
  List<Plan> _plans = [];
  GymInfo _gymInfo = GymInfo();
  bool _loading = true;

  List<Member> get members => _members;
  List<Plan> get plans => _plans;
  GymInfo get gymInfo => _gymInfo;
  bool get loading => _loading;

  final _uuid = const Uuid();

  // ── Stats ──────────────────────────────────────────────────
  int get totalMembers => _members.length;
  int get activeMembers =>
      _members.where((m) => !m.isExpired).length;
  int get expiredMembers =>
      _members.where((m) => m.isExpired).length;
  int get expiringSoon =>
      _members.where((m) => m.isExpiringSoon).length;

  double get totalRevenue =>
      _members.fold(0, (sum, m) => sum + m.amountPaid);
  double get totalDue =>
      _members.fold(0, (sum, m) => sum + m.amountDue);

  double get monthlyRevenue {
    final now = DateTime.now();
    return _members.fold(0.0, (sum, m) {
      final monthPayments = m.payments.where((p) =>
          p.date.month == now.month && p.date.year == now.year);
      return sum + monthPayments.fold(0.0, (s, p) => s + p.amount);
    });
  }

  List<Member> get recentMembers {
    final sorted = [..._members]
      ..sort((a, b) => b.joinDate.compareTo(a.joinDate));
    return sorted.take(5).toList();
  }

  // ── Init ──────────────────────────────────────────────────
  Future<void> init() async {
    _members = await DataStore.loadMembers();
    _plans = await DataStore.loadPlans();
    _gymInfo = await DataStore.loadGymInfo();
    _loading = false;
    notifyListeners();
  }

  // ── Members ───────────────────────────────────────────────
  Future<void> addMember(Member member) async {
    _members.add(member);
    await DataStore.saveMembers(_members);
    notifyListeners();
  }

  Future<void> updateMember(Member updated) async {
    final idx = _members.indexWhere((m) => m.id == updated.id);
    if (idx >= 0) {
      _members[idx] = updated;
      await DataStore.saveMembers(_members);
      notifyListeners();
    }
  }

  Future<void> deleteMember(String id) async {
    _members.removeWhere((m) => m.id == id);
    await DataStore.saveMembers(_members);
    notifyListeners();
  }

  Future<void> addPayment(String memberId, PaymentRecord payment) async {
    final idx = _members.indexWhere((m) => m.id == memberId);
    if (idx >= 0) {
      _members[idx].payments.add(payment);
      _members[idx].amountPaid += payment.amount;
      if (_members[idx].amountDue > 0) {
        _members[idx].amountDue =
            (_members[idx].amountDue - payment.amount).clamp(0, double.infinity);
      }
      await DataStore.saveMembers(_members);
      notifyListeners();
    }
  }

  Future<void> renewMember(String memberId, String planId) async {
    final idx = _members.indexWhere((m) => m.id == memberId);
    final planIdx = _plans.indexWhere((p) => p.id == planId);
    if (idx >= 0 && planIdx >= 0) {
      final plan = _plans[planIdx];
      final base = _members[idx].expiryDate.isAfter(DateTime.now())
          ? _members[idx].expiryDate
          : DateTime.now();
      _members[idx].expiryDate =
          base.add(Duration(days: plan.durationDays));
      _members[idx].planId = planId;
      _members[idx].status = 'active';
      await DataStore.saveMembers(_members);
      notifyListeners();
    }
  }

  String generateMemberId() => _uuid.v4();
  String generatePaymentId() => _uuid.v4();

  Member? getMemberById(String id) {
    try {
      return _members.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Plan? getPlanById(String id) {
    try {
      return _plans.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Member> searchMembers(String query) {
    if (query.isEmpty) return _members;
    final q = query.toLowerCase();
    return _members
        .where((m) =>
            m.name.toLowerCase().contains(q) ||
            m.phone.contains(q) ||
            m.email.toLowerCase().contains(q))
        .toList();
  }

  // ── Plans ─────────────────────────────────────────────────
  Future<void> addPlan(Plan plan) async {
    _plans.add(plan);
    await DataStore.savePlans(_plans);
    notifyListeners();
  }

  Future<void> updatePlan(Plan updated) async {
    final idx = _plans.indexWhere((p) => p.id == updated.id);
    if (idx >= 0) {
      _plans[idx] = updated;
      await DataStore.savePlans(_plans);
      notifyListeners();
    }
  }

  Future<void> deletePlan(String id) async {
    _plans.removeWhere((p) => p.id == id);
    await DataStore.savePlans(_plans);
    notifyListeners();
  }

  // ── Gym Info ──────────────────────────────────────────────
  Future<void> updateGymInfo(GymInfo info) async {
    _gymInfo = info;
    await DataStore.saveGymInfo(info);
    notifyListeners();
  }
}
