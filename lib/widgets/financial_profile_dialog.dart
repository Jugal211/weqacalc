import 'package:flutter/material.dart';
import 'package:weqacalc/services/user_data_service.dart';

class FinancialProfileDialog extends StatefulWidget {
  final UserDataService userDataService;

  const FinancialProfileDialog({super.key, required this.userDataService});

  @override
  State<FinancialProfileDialog> createState() => _FinancialProfileDialogState();
}

class _FinancialProfileDialogState extends State<FinancialProfileDialog> {
  final _monthlyIncomeController = TextEditingController();
  final _monthlySavingsController = TextEditingController();
  final _totalDebtController = TextEditingController();
  bool _hasEmergencyFund = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final income = widget.userDataService.getMonthlyIncome();
    final savings = widget.userDataService.getMonthlySavings();
    final debt = widget.userDataService.getTotalDebt();
    final emergencyFund = widget.userDataService.getHasEmergencyFund();

    setState(() {
      _monthlyIncomeController.text = income > 0
          ? income.toStringAsFixed(0)
          : '';
      _monthlySavingsController.text = savings > 0
          ? savings.toStringAsFixed(0)
          : '';
      _totalDebtController.text = debt > 0 ? debt.toStringAsFixed(0) : '';
      _hasEmergencyFund = emergencyFund;
    });
  }

  Future<void> _saveProfile() async {
    final income = double.tryParse(_monthlyIncomeController.text) ?? 0;
    final savings = double.tryParse(_monthlySavingsController.text) ?? 0;
    final debt = double.tryParse(_totalDebtController.text) ?? 0;

    await widget.userDataService.setMonthlyIncome(income);
    await widget.userDataService.setMonthlySavings(savings);
    await widget.userDataService.setTotalDebt(debt);
    await widget.userDataService.setHasEmergencyFund(_hasEmergencyFund);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Financial profile updated!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.blue.shade600,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Financial Profile',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Help us personalize your experience',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _monthlyIncomeController,
                label: 'Monthly Income',
                hint: 'Enter your monthly income',
                icon: Icons.currency_rupee,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _monthlySavingsController,
                label: 'Monthly Savings/Investment',
                hint: 'How much do you save/invest',
                icon: Icons.savings,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _totalDebtController,
                label: 'Total Outstanding Debt',
                hint: 'All loans combined',
                icon: Icons.credit_card,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.security,
                      color: Colors.green.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Do you have an emergency fund?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Switch(
                      value: _hasEmergencyFund,
                      onChanged: (value) {
                        setState(() {
                          _hasEmergencyFund = value;
                        });
                      },
                      activeTrackColor: Colors.green.shade300,
                      activeThumbColor: Colors.green.shade600,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '💡 Tip: These values help us calculate a more accurate Financial Health Score',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Save Profile',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.blue.shade600),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _monthlyIncomeController.dispose();
    _monthlySavingsController.dispose();
    _totalDebtController.dispose();
    super.dispose();
  }
}
