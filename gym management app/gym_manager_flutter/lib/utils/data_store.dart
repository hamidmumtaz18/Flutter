// lib/utils/data_store.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member.dart';
import '../models/plan.dart';
import '../models/gym_info.dart';

class DataStore {
  static const _membersKey = 'members';
  static const _plansKey = 'plans';
  static const _gymInfoKey = 'gym_info';

  static Future<List<Member>> loadMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_membersKey);
    if (raw == null) return [];
    final List<dynamic> list = jsonDecode(raw);
    return list.map((e) => Member.fromJson(e)).toList();
  }

  static Future<void> saveMembers(List<Member> members) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _membersKey, jsonEncode(members.map((m) => m.toJson()).toList()));
  }

  static Future<List<Plan>> loadPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_plansKey);
    if (raw == null) return Plan.defaultPlans();
    final List<dynamic> list = jsonDecode(raw);
    return list.map((e) => Plan.fromJson(e)).toList();
  }

  static Future<void> savePlans(List<Plan> plans) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _plansKey, jsonEncode(plans.map((p) => p.toJson()).toList()));
  }

  static Future<GymInfo> loadGymInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_gymInfoKey);
    if (raw == null) return GymInfo();
    return GymInfo.fromJson(jsonDecode(raw));
  }

  static Future<void> saveGymInfo(GymInfo info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gymInfoKey, jsonEncode(info.toJson()));
  }
}
