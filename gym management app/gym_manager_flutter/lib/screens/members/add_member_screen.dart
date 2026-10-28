// lib/screens/members/add_member_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../../models/member.dart';

class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _ageCtrl = TextEditingController(text: '25');
  final _amountPaidCtrl = TextEditingController();
  final _amountDueCtrl = TextEditingController(text: '0');

  String _selectedPlanId = '';
  String _gender = 'Male';
  DateTime _joinDate = DateTime.now();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final plans = state.plans.where((p) => p.isActive).toList();
    if (_selectedPlanId.isEmpty && plans.isNotEmpty) {
      _selectedPlanId = plans.first.id;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Member')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Personal Info'),
              const SizedBox(height: 12),
              _field(_nameCtrl, 'Full Name', Icons.person,
                  validator: (v) => v!.isEmpty ? 'Name required' : null),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Phone Number', Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.length < 10 ? 'Valid phone required' : null),
              const SizedBox(height: 12),
              _field(_emailCtrl, 'Email (optional)', Icons.email,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _field(_ageCtrl, 'Age', Icons.cake,
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _gender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        prefixIcon: const Icon(Icons.wc, color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white12)),
                      ),
                      dropdownColor: AppTheme.card,
                      items: ['Male', 'Female', 'Other']
                          .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(g,
                                  style: const TextStyle(color: AppTheme.textLight))))
                          .toList(),
                      onChanged: (v) => setState(() => _gender = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _field(_addressCtrl, 'Address (optional)', Icons.home),
              const SizedBox(height: 20),

              _sectionLabel('Membership'),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedPlanId.isEmpty ? null : _selectedPlanId,
                decoration: InputDecoration(
                  labelText: 'Select Plan',
                  prefixIcon: const Icon(Icons.card_membership, color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.surface,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white12)),
                ),
                dropdownColor: AppTheme.card,
                items: plans
                    .map((p) => DropdownMenuItem(
                          value: p.id,
                          child: Text('${p.name} — ₹${p.price.toStringAsFixed(0)}',
                              style: const TextStyle(color: AppTheme.textLight)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedPlanId = v!),
                validator: (v) => v == null ? 'Select a plan' : null,
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _joinDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.dark(
                            primary: AppTheme.primary,
                            surface: AppTheme.card),
                      ),
                      child: child!,
                    ),
                  );
                  if (d != null) setState(() => _joinDate = d);
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppTheme.textMuted, size: 20),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Join Date',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                          Text(
                            '${_joinDate.day}/${_joinDate.month}/${_joinDate.year}',
                            style: const TextStyle(
                                color: AppTheme.textLight, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.edit, color: AppTheme.primary, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _sectionLabel('Payment'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _field(_amountPaidCtrl, 'Amount Paid (₹)', Icons.payments,
                        keyboardType: TextInputType.number),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _field(_amountDueCtrl, 'Amount Due (₹)', Icons.pending,
                        keyboardType: TextInputType.number),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Add Member'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1),
      );

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: const TextStyle(color: AppTheme.textLight),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.textMuted),
        ),
        validator: validator,
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPlanId.isEmpty) return;

    setState(() => _saving = true);

    final state = context.read<AppState>();
    final plan = state.getPlanById(_selectedPlanId)!;
    final expiryDate = _joinDate.add(Duration(days: plan.durationDays));

    final member = Member(
      id: state.generateMemberId(),
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      planId: _selectedPlanId,
      joinDate: _joinDate,
      expiryDate: expiryDate,
      gender: _gender,
      age: int.tryParse(_ageCtrl.text) ?? 25,
      address: _addressCtrl.text.trim(),
      amountPaid: double.tryParse(_amountPaidCtrl.text) ?? 0,
      amountDue: double.tryParse(_amountDueCtrl.text) ?? 0,
    );

    await state.addMember(member);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Member added successfully!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _ageCtrl.dispose();
    _amountPaidCtrl.dispose();
    _amountDueCtrl.dispose();
    super.dispose();
  }
}
