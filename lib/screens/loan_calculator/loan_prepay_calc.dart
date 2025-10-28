import 'package:flutter/material.dart';
import 'dart:math';

class LoanPrepaymentCalculator extends StatefulWidget {
  const LoanPrepaymentCalculator({super.key});

  @override
  State<LoanPrepaymentCalculator> createState() =>
      _LoanPrepaymentCalculatorState();
}

class _LoanPrepaymentCalculatorState extends State<LoanPrepaymentCalculator> {
  final _loanAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _loanTenureController = TextEditingController();
  final _stepUpController = TextEditingController();
  final _extraPaymentController = TextEditingController();

  double _loanAmount = 5000000;
  double _interestRate = 8.5;
  int _loanTenure = 20;
  double _stepUpPercentage = 5;
  double _extraPaymentPerYear = 50000;

  double _regularEMI = 0;
  double _regularTotalAmount = 0;
  double _regularTotalInterest = 0;

  double _prepaymentEMI = 0;
  double _prepaymentTotalAmount = 0;
  double _prepaymentTotalInterest = 0;
  int _prepaymentTenure = 0;

  double _totalSavings = 0;
  int _timeSaved = 0;

  @override
  void initState() {
    super.initState();
    _loanAmountController.text = _loanAmount.toStringAsFixed(0);
    _interestRateController.text = _interestRate.toStringAsFixed(1);
    _loanTenureController.text = _loanTenure.toString();
    _stepUpController.text = _stepUpPercentage.toStringAsFixed(1);
    _extraPaymentController.text = _extraPaymentPerYear.toStringAsFixed(0);
    _calculate();
  }

  void _calculate() {
    _calculateRegularLoan();
    _calculatePrepaymentLoan();
    _calculateSavings();
    setState(() {});
  }

  void _calculateRegularLoan() {
    double principal = _loanAmount;
    double monthlyRate = _interestRate / 12 / 100;
    int months = _loanTenure * 12;

    if (monthlyRate == 0) {
      _regularEMI = principal / months;
    } else {
      _regularEMI =
          principal *
          monthlyRate *
          pow(1 + monthlyRate, months) /
          (pow(1 + monthlyRate, months) - 1);
    }

    _regularTotalAmount = _regularEMI * months;
    _regularTotalInterest = _regularTotalAmount - principal;
  }

  void _calculatePrepaymentLoan() {
    double balance = _loanAmount;
    double monthlyRate = _interestRate / 12 / 100;
    double currentEMI = _regularEMI;
    int monthsPassed = 0;
    double totalPaid = 0;

    while (balance > 0 && monthsPassed < _loanTenure * 12 * 2) {
      int currentYear = monthsPassed ~/ 12;

      // Apply step-up at the beginning of each year
      if (monthsPassed > 0 && monthsPassed % 12 == 0) {
        currentEMI = currentEMI * (1 + _stepUpPercentage / 100);
      }

      double interest = balance * monthlyRate;
      double principal = currentEMI - interest;

      if (principal <= 0) {
        principal = 0.01; // Prevent infinite loop
      }

      balance -= principal;
      totalPaid += currentEMI;

      // Add extra payment at the end of each year
      if ((monthsPassed + 1) % 12 == 0 && balance > 0) {
        double extraPayment = min(_extraPaymentPerYear, balance);
        balance -= extraPayment;
        totalPaid += extraPayment;
      }

      monthsPassed++;

      if (balance <= 0) break;
    }

    _prepaymentTenure = monthsPassed;
    _prepaymentTotalAmount = totalPaid;
    _prepaymentTotalInterest = totalPaid - _loanAmount;
    _prepaymentEMI = currentEMI;
  }

  void _calculateSavings() {
    _totalSavings = _regularTotalInterest - _prepaymentTotalInterest;
    _timeSaved = (_loanTenure * 12) - _prepaymentTenure;
  }

  List<Map<String, dynamic>> _getYearlyBreakdown() {
    List<Map<String, dynamic>> breakdown = [];
    double balance = _loanAmount;
    double monthlyRate = _interestRate / 12 / 100;
    double currentEMI = _regularEMI;
    int monthsPassed = 0;

    for (int year = 1; year <= _loanTenure && balance > 0; year++) {
      double yearlyPrincipal = 0;
      double yearlyInterest = 0;
      double yearlyEMI = 0;

      // Apply step-up at the beginning of each year (except first year)
      if (year > 1) {
        currentEMI = currentEMI * (1 + _stepUpPercentage / 100);
      }

      for (int month = 0; month < 12 && balance > 0; month++) {
        double interest = balance * monthlyRate;
        double principal = currentEMI - interest;

        if (principal > balance) {
          principal = balance;
        }

        balance -= principal;
        yearlyPrincipal += principal;
        yearlyInterest += interest;
        yearlyEMI += currentEMI;
        monthsPassed++;
      }

      // Add extra payment at end of year
      double extraPayment = 0;
      if (balance > 0) {
        extraPayment = min(_extraPaymentPerYear, balance);
        balance -= extraPayment;
        yearlyPrincipal += extraPayment;
      }

      breakdown.add({
        'year': year,
        'emi': currentEMI,
        'principal': yearlyPrincipal,
        'interest': yearlyInterest,
        'extraPayment': extraPayment,
        'totalPaid': yearlyEMI + extraPayment,
        'balance': max(0, balance),
      });

      if (balance <= 0) break;
    }

    return breakdown;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Prepayment Calculator'),
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputCard(),
                  const SizedBox(height: 20),
                  _buildComparisonCards(),
                  const SizedBox(height: 20),
                  _buildSavingsCard(),
                  const SizedBox(height: 20),
                  _buildYearlyBreakdown(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.purple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.trending_down_rounded,
            size: 70,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          const Text(
            'Total Savings',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_totalSavings.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Save $_timeSaved months',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Loan Details',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Loan Amount',
            value: _loanAmount,
            min: 100000,
            max: 50000000,
            divisions: 500,
            prefix: '₹',
            controller: _loanAmountController,
            onChanged: (val) {
              setState(() {
                _loanAmount = val;
                _loanAmountController.text = val.toStringAsFixed(0);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Interest Rate (% p.a.)',
            value: _interestRate,
            min: 1,
            max: 20,
            divisions: 190,
            suffix: '%',
            controller: _interestRateController,
            onChanged: (val) {
              setState(() {
                _interestRate = val;
                _interestRateController.text = val.toStringAsFixed(1);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Loan Tenure',
            value: _loanTenure.toDouble(),
            min: 1,
            max: 30,
            divisions: 29,
            suffix: ' Years',
            controller: _loanTenureController,
            onChanged: (val) {
              setState(() {
                _loanTenure = val.toInt();
                _loanTenureController.text = val.toInt().toString();
                _calculate();
              });
            },
          ),
          const SizedBox(height: 32),
          const Text(
            'Prepayment Options',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'EMI Step-Up (% per year)',
            value: _stepUpPercentage,
            min: 0,
            max: 20,
            divisions: 40,
            suffix: '%',
            controller: _stepUpController,
            onChanged: (val) {
              setState(() {
                _stepUpPercentage = val;
                _stepUpController.text = val.toStringAsFixed(1);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Extra Payment per Year',
            value: _extraPaymentPerYear,
            min: 0,
            max: 1000000,
            divisions: 100,
            prefix: '₹',
            controller: _extraPaymentController,
            onChanged: (val) {
              setState(() {
                _extraPaymentPerYear = val;
                _extraPaymentController.text = val.toStringAsFixed(0);
                _calculate();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliderInput({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    String prefix = '',
    String suffix = '',
    required Function(double) onChanged,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _showEditDialog(
                  context: context,
                  title: label,
                  controller: controller,
                  prefix: prefix,
                  suffix: suffix,
                  min: min,
                  max: max,
                  onSave: (val) {
                    onChanged(val);
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.purple.shade200, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$prefix${value.toStringAsFixed(suffix == '%' ? 1 : 0)}$suffix',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit, size: 16, color: Colors.purple.shade700),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.purple.shade600,
            inactiveTrackColor: Colors.purple.shade100,
            thumbColor: Colors.purple.shade700,
            overlayColor: Colors.purple.shade100,
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: (val) {
              controller.text = val.toStringAsFixed(suffix == '%' ? 1 : 0);
              onChanged(val);
            },
          ),
        ),
      ],
    );
  }

  void _showEditDialog({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required String prefix,
    required String suffix,
    required double min,
    required double max,
    required Function(double) onSave,
  }) {
    final tempController = TextEditingController(text: controller.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter $title'),
        content: TextField(
          controller: tempController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            prefixText: prefix,
            suffixText: suffix,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.purple.shade600, width: 2),
            ),
            hintText: 'Enter value between $min and $max',
          ),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(tempController.text);
              if (value != null && value >= min && value <= max) {
                controller.text = tempController.text;
                onSave(value);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a value between $min and $max'),
                    backgroundColor: Colors.red.shade400,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildComparisonCard(
                'Regular Loan',
                _regularEMI,
                _regularTotalAmount,
                _regularTotalInterest,
                _loanTenure * 12,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildComparisonCard(
                'With Prepayment',
                _prepaymentEMI,
                _prepaymentTotalAmount,
                _prepaymentTotalInterest,
                _prepaymentTenure,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonCard(
    String title,
    double emi,
    double total,
    double interest,
    int tenure,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          _buildComparisonRow('EMI', '₹${emi.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildComparisonRow('Total', '₹${total.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildComparisonRow('Interest', '₹${interest.toStringAsFixed(0)}'),
          const SizedBox(height: 8),
          _buildComparisonRow(
            'Tenure',
            '${(tenure / 12).toStringAsFixed(1)} yrs',
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade800,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSavingsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.purple.shade400],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Your Savings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSavingItem(
                  Icons.savings_rounded,
                  'Interest Saved',
                  '₹${_totalSavings.toStringAsFixed(0)}',
                ),
              ),
              Container(
                width: 1,
                height: 60,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildSavingItem(
                  Icons.timer_rounded,
                  'Time Saved',
                  '${(_timeSaved / 12).toStringAsFixed(1)} years',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavingItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.white70),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildYearlyBreakdown() {
    final breakdown = _getYearlyBreakdown();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yearly Payment Schedule',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'With step-up EMI and extra payments',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
              border: TableBorder.all(color: Colors.grey.shade300, width: 1),
              columnSpacing: 20,
              columns: const [
                DataColumn(
                  label: Text(
                    'Year',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'EMI',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Principal',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Interest',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Extra Pay',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Balance',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
              rows: breakdown.map((row) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        '${row['year']}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['emi']).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['principal']).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['interest']).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['extraPayment']).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['balance']).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _loanAmountController.dispose();
    _interestRateController.dispose();
    _loanTenureController.dispose();
    _stepUpController.dispose();
    _extraPaymentController.dispose();
    super.dispose();
  }
}
