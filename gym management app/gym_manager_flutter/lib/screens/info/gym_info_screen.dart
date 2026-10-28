// lib/screens/info/gym_info_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../../models/gym_info.dart';

class GymInfoScreen extends StatefulWidget {
  const GymInfoScreen({super.key});

  @override
  State<GymInfoScreen> createState() => _GymInfoScreenState();
}

class _GymInfoScreenState extends State<GymInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _ownerCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _addressCtrl;
  late TextEditingController _cityCtrl;
  late TextEditingController _taglineCtrl;
  late TextEditingController _openCtrl;
  late TextEditingController _closeCtrl;
  late TextEditingController _gstCtrl;
  late TextEditingController _websiteCtrl;
  late TextEditingController _igCtrl;
  List<String> _workingDays = [];
  bool _saving = false;

  final _allDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    final info = context.read<AppState>().gymInfo;
    _nameCtrl = TextEditingController(text: info.name);
    _ownerCtrl = TextEditingController(text: info.ownerName);
    _phoneCtrl = TextEditingController(text: info.phone);
    _emailCtrl = TextEditingController(text: info.email);
    _addressCtrl = TextEditingController(text: info.address);
    _cityCtrl = TextEditingController(text: info.city);
    _taglineCtrl = TextEditingController(text: info.tagline);
    _openCtrl = TextEditingController(text: info.openTime);
    _closeCtrl = TextEditingController(text: info.closeTime);
    _gstCtrl = TextEditingController(text: info.gstNumber);
    _websiteCtrl = TextEditingController(text: info.website);
    _igCtrl = TextEditingController(text: info.instagramHandle);
    _workingDays = List.from(info.workingDays);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Info'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('SAVE',
                style: TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gym identity
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppTheme.primary.withOpacity(0.2),
                      child: const Icon(Icons.fitness_center,
                          color: AppTheme.primary, size: 48),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _sectionLabel('GYM DETAILS'),
              const SizedBox(height: 12),
              _field(_nameCtrl, 'Gym Name', Icons.fitness_center,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 12),
              _field(_taglineCtrl, 'Tagline', Icons.format_quote),
              const SizedBox(height: 12),
              _field(_ownerCtrl, 'Owner Name', Icons.person,
                  validator: (v) => v!.isEmpty ? 'Required' : null),
              const SizedBox(height: 20),

              _sectionLabel('CONTACT'),
              const SizedBox(height: 12),
              _field(_phoneCtrl, 'Phone Number', Icons.phone,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _field(_emailCtrl, 'Email', Icons.email,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 12),
              _field(_websiteCtrl, 'Website', Icons.language),
              const SizedBox(height: 12),
              _field(_igCtrl, 'Instagram Handle', Icons.camera_alt),
              const SizedBox(height: 20),

              _sectionLabel('LOCATION'),
              const SizedBox(height: 12),
              _field(_addressCtrl, 'Address', Icons.location_on),
              const SizedBox(height: 12),
              _field(_cityCtrl, 'City', Icons.location_city),
              const SizedBox(height: 12),
              _field(_gstCtrl, 'GST Number', Icons.receipt),
              const SizedBox(height: 20),

              _sectionLabel('TIMINGS'),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _field(_openCtrl, 'Opens At', Icons.wb_sunny)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _field(_closeCtrl, 'Closes At', Icons.nights_stay)),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Working Days',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _allDays.map((d) {
                  final isSelected = _workingDays.contains(d);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _workingDays.remove(d);
                        } else {
                          _workingDays.add(d);
                        }
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primary
                            : AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : Colors.white12,
                        ),
                      ),
                      child: Text(
                        d,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Save Gym Info'),
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
            fontSize: 11,
            letterSpacing: 1.5),
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final state = context.read<AppState>();
    await state.updateGymInfo(GymInfo(
      name: _nameCtrl.text.trim(),
      ownerName: _ownerCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      tagline: _taglineCtrl.text.trim(),
      openTime: _openCtrl.text.trim(),
      closeTime: _closeCtrl.text.trim(),
      workingDays: _workingDays,
      gstNumber: _gstCtrl.text.trim(),
      website: _websiteCtrl.text.trim(),
      instagramHandle: _igCtrl.text.trim(),
    ));
    if (mounted) {
      setState(() => _saving = false);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gym info saved!'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ownerCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _taglineCtrl.dispose();
    _openCtrl.dispose();
    _closeCtrl.dispose();
    _gstCtrl.dispose();
    _websiteCtrl.dispose();
    _igCtrl.dispose();
    super.dispose();
  }
}
