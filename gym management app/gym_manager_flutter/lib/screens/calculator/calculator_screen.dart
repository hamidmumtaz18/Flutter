// lib/screens/calculator/calculator_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/app_state.dart';
import '../../models/plan.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  Plan? _selectedPlan;
  double _discount = 0;
  double _additionalFees = 0;
  double _advanceAmount = 0;
  int _months = 1;

  final _discountCtrl = TextEditingController();
  final _addFeeCtrl = TextEditingController();
  final _advanceCtrl = TextEditingController();

  // Custom calculator
  final List<String> _calcInput = [];
  String _calcDisplay = '0';
  double? _calcResult;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final plans = state.plans.where((p) => p.isActive).toList();
    if (_selectedPlan == null && plans.isNotEmpty) {
      _selectedPlan = plans.first;
    }

    double basePrice = (_selectedPlan?.price ?? 0) * _months;
    double discountAmt = _discountCtrl.text.endsWith('%')
        ? basePrice * (_discount / 100)
        : _discount;
    double afterDiscount = basePrice - discountAmt;
    double total = afterDiscount + _additionalFees;
    double due = total - _advanceAmount;

    return Scaffold(
      appBar: AppBar(title: const Text('Fee Calculator')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan selector
            _sectionLabel('Select Plan'),
            const SizedBox(height: 10),
            ...plans.map((p) {
              final isSelected = _selectedPlan?.id == p.id;
              final color = _hexToColor(p.color);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPlan = p;
                    _months = 1;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isSelected ? color.withOpacity(0.15) : AppTheme.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: isSelected ? color : Colors.white12,
                        width: isSelected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.card_membership,
                          color: isSelected ? color : AppTheme.textMuted),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: TextStyle(
                                    color: isSelected ? color : AppTheme.textLight,
                                    fontWeight: FontWeight.bold)),
                            Text(p.durationLabel,
                                style: const TextStyle(
                                    color: AppTheme.textMuted, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text('₹${p.price.toStringAsFixed(0)}',
                          style: TextStyle(
                              color: isSelected ? color : AppTheme.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            _sectionLabel('Months'),
            const SizedBox(height: 10),
            Row(
              children: [1, 2, 3, 6, 12].map((m) {
                final isSelected = _months == m;
                return GestureDetector(
                  onTap: () => setState(() => _months = m),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : AppTheme.card,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${m}m',
                      style: TextStyle(
                          color:
                              isSelected ? Colors.white : AppTheme.textMuted,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            _sectionLabel('Adjustments'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _discountCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textLight),
                    decoration: const InputDecoration(
                      labelText: 'Discount (₹ or %)',
                      prefixIcon: Icon(Icons.local_offer, color: AppTheme.textMuted),
                    ),
                    onChanged: (v) =>
                        setState(() => _discount = double.tryParse(v.replaceAll('%', '')) ?? 0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _addFeeCtrl,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textLight),
                    decoration: const InputDecoration(
                      labelText: 'Extra Fees (₹)',
                      prefixIcon: Icon(Icons.add_circle_outline, color: AppTheme.textMuted),
                    ),
                    onChanged: (v) =>
                        setState(() => _additionalFees = double.tryParse(v) ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _advanceCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppTheme.textLight),
              decoration: const InputDecoration(
                labelText: 'Advance Paid (₹)',
                prefixIcon: Icon(Icons.payments, color: AppTheme.textMuted),
              ),
              onChanged: (v) =>
                  setState(() => _advanceAmount = double.tryParse(v) ?? 0),
            ),

            const SizedBox(height: 20),
            // Result card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.card, AppTheme.surface],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  const Text('Fee Summary',
                      style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  const SizedBox(height: 16),
                  _calcRow('Base Fee', '₹${basePrice.toStringAsFixed(0)}'),
                  if (discountAmt > 0)
                    _calcRow('Discount',
                        '- ₹${discountAmt.toStringAsFixed(0)}',
                        valueColor: AppTheme.success),
                  if (_additionalFees > 0)
                    _calcRow('Extra Fees',
                        '+ ₹${_additionalFees.toStringAsFixed(0)}',
                        valueColor: AppTheme.warning),
                  const Divider(color: Colors.white12, height: 20),
                  _calcRow('Total', '₹${total.toStringAsFixed(0)}',
                      isBold: true),
                  if (_advanceAmount > 0) ...[
                    _calcRow('Advance',
                        '- ₹${_advanceAmount.toStringAsFixed(0)}',
                        valueColor: AppTheme.success),
                    const Divider(color: Colors.white12, height: 20),
                    _calcRow(
                      'Balance Due',
                      '₹${due.toStringAsFixed(0)}',
                      isBold: true,
                      valueColor: due > 0 ? AppTheme.error : AppTheme.success,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
            _sectionLabel('Quick Calculator'),
            const SizedBox(height: 10),
            _buildNumpad(context),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _calcRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: AppTheme.textMuted,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? AppTheme.textLight,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: isBold ? 16 : 14)),
        ],
      ),
    );
  }

  Widget _buildNumpad(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _calcResult != null
                  ? '= ${_calcResult!.toStringAsFixed(2)}'
                  : _calcDisplay,
              style: const TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 28,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 12),
          ..._buildNumpadButtons(),
        ],
      ),
    );
  }

  List<Widget> _buildNumpadButtons() {
    final buttons = [
      ['7', '8', '9', '÷'],
      ['4', '5', '6', '×'],
      ['1', '2', '3', '-'],
      ['C', '0', '=', '+'],
    ];

    return buttons.map((row) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: row.map((btn) {
            final isOp = ['÷', '×', '-', '+', '=', 'C'].contains(btn);
            Color btnColor = isOp ? AppTheme.primary : AppTheme.surface;
            if (btn == 'C') btnColor = AppTheme.error;
            if (btn == '=') btnColor = AppTheme.success;

            return Expanded(
              child: GestureDetector(
                onTap: () => _onCalcTap(btn),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 56,
                  decoration: BoxDecoration(
                    color: btnColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(btn,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }).toList();
  }

  void _onCalcTap(String val) {
    setState(() {
      _calcResult = null;
      if (val == 'C') {
        _calcInput.clear();
        _calcDisplay = '0';
        return;
      }
      if (val == '=') {
        try {
          final expr = _calcDisplay
              .replaceAll('÷', '/')
              .replaceAll('×', '*');
          // Simple two-operand evaluation
          for (final op in ['+', '-', '*', '/']) {
            final parts = expr.split(op);
            if (parts.length == 2) {
              final a = double.tryParse(parts[0]) ?? 0;
              final b = double.tryParse(parts[1]) ?? 0;
              if (op == '+') _calcResult = a + b;
              if (op == '-') _calcResult = a - b;
              if (op == '*') _calcResult = a * b;
              if (op == '/') _calcResult = b != 0 ? a / b : 0;
              _calcDisplay = expr;
              return;
            }
          }
        } catch (_) {}
        return;
      }

      if (_calcDisplay == '0' && !['÷', '×', '-', '+'].contains(val)) {
        _calcDisplay = val;
      } else {
        _calcDisplay += val;
      }
    });
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            color: AppTheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1),
      );

  Color _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppTheme.primary;
    }
  }

  @override
  void dispose() {
    _discountCtrl.dispose();
    _addFeeCtrl.dispose();
    _advanceCtrl.dispose();
    super.dispose();
  }
}
