import 'package:flutter/material.dart';
import 'dart:math';
import 'package:weqacalc/utils/utils.dart';

class EPFCalculator extends StatefulWidget {
  const EPFCalculator({super.key});

  @override
  State<EPFCalculator> createState() => _EPFCalculatorState();
}

class _EPFCalculatorState extends State<EPFCalculator> {
  final _monthlySalaryController = TextEditingController();
  final _yourAgeController = TextEditingController();
  final _contributionController = TextEditingController();
  final _salaryIncreaseController = TextEditingController();

  double _monthlySalary = 50000;
  int _yourAge = 25;
  double _contributionPercent = 12;
  double _salaryIncreasePercent = 5;
  final double _rateOfInterest = 8.25; // Fixed rate
  final int _retirementAge = 58;

  double _totalContribution = 0;
  double _totalInterest = 0;
  double _maturityAmount = 0;
  int _yearsToRetirement = 0;

  @override
  void initState() {
    super.initState();
    _monthlySalaryController.text = _monthlySalary.toStringAsFixed(0);
    _yourAgeController.text = _yourAge.toString();
    _contributionController.text = _contributionPercent.toStringAsFixed(0);
    _salaryIncreaseController.text = _salaryIncreasePercent.toStringAsFixed(0);
    _calculate();
  }

  void _calculate() {
    _yearsToRetirement = _retirementAge - _yourAge;

    double balance = 0;
    double currentSalary = _monthlySalary;
    double totalContributed = 0;

    // EPF Calculation
    for (int year = 1; year <= _yearsToRetirement; year++) {
      // Monthly contribution (Employee + Employer)
      double monthlyContribution =
          (currentSalary * _contributionPercent / 100) *
          2; // Both employee and employer contribute

      // Add contributions for 12 months
      for (int month = 1; month <= 12; month++) {
        balance += monthlyContribution;
        totalContributed += monthlyContribution;
      }

      // Add annual interest
      double interest = balance * (_rateOfInterest / 100);
      balance += interest;

      // Increase salary for next year
      currentSalary = currentSalary * (1 + _salaryIncreasePercent / 100);
    }

    _maturityAmount = balance;
    _totalContribution = totalContributed;
    _totalInterest = _maturityAmount - _totalContribution;

    setState(() {});
  }

  List<Map<String, dynamic>> _getYearlyBreakdown() {
    List<Map<String, dynamic>> breakdown = [];
    double balance = 0;
    double currentSalary = _monthlySalary;
    int currentAge = _yourAge;

    for (int year = 0; year <= _yearsToRetirement; year++) {
      if (year == 0) {
        breakdown.add({
          'year': year,
          'age': currentAge,
          'salary': currentSalary,
          'contribution': 0.0,
          'interest': 0.0,
          'balance': 0.0,
        });
        continue;
      }

      // Monthly contribution (Employee + Employer)
      double monthlyContribution =
          (currentSalary * _contributionPercent / 100) * 2;
      double yearlyContribution = monthlyContribution * 12;

      // Add contributions
      balance += yearlyContribution;

      // Calculate interest
      double interest = balance * (_rateOfInterest / 100);
      balance += interest;

      breakdown.add({
        'year': year,
        'age': currentAge + year,
        'salary': currentSalary,
        'contribution': yearlyContribution,
        'interest': interest,
        'balance': balance,
      });

      // Increase salary for next year
      currentSalary = currentSalary * (1 + _salaryIncreasePercent / 100);
    }

    return breakdown;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EPF Calculator'),
        backgroundColor: Colors.teal.shade600,
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
                  _buildResultCards(),
                  const SizedBox(height: 20),
                  _buildBreakdownChart(),
                  const SizedBox(height: 20),
                  _buildYearlyBreakdown(),
                  const SizedBox(height: 20),
                  _buildInfoCard(),
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
          colors: [Colors.teal.shade600, Colors.teal.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_wallet_rounded,
            size: 70,
            color: Colors.white,
          ),
          const SizedBox(height: 20),
          const Text(
            'You will have accumulated',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_maturityAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'by the time you retire (Age $_retirementAge)',
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
            'EPF Details',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Monthly Salary (Basic + DA)',
            value: _monthlySalary,
            min: 5000,
            max: 200000,
            divisions: 390,
            prefix: '₹',
            controller: _monthlySalaryController,
            onChanged: (val) {
              setState(() {
                _monthlySalary = val;
                _monthlySalaryController.text = val.toStringAsFixed(0);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Your Age',
            value: _yourAge.toDouble(),
            min: 15,
            max: 58,
            divisions: 43,
            suffix: ' Yr',
            controller: _yourAgeController,
            onChanged: (val) {
              setState(() {
                _yourAge = val.toInt();
                _yourAgeController.text = val.toInt().toString();
                _calculate();
              });
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You have $_yearsToRetirement years until retirement (Age $_retirementAge)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Your Contribution to EPF',
            value: _contributionPercent,
            min: 12,
            max: 20,
            divisions: 80,
            suffix: '%',
            controller: _contributionController,
            onChanged: (val) {
              setState(() {
                _contributionPercent = val;
                _contributionController.text = val.toStringAsFixed(1);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Employer also contributes ${_contributionPercent.toStringAsFixed(1)}% (Total: ${(_contributionPercent * 2).toStringAsFixed(1)}%)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Annual Increase in Salary',
            value: _salaryIncreasePercent,
            min: 0,
            max: 20,
            divisions: 200,
            suffix: '%',
            controller: _salaryIncreaseController,
            onChanged: (val) {
              setState(() {
                _salaryIncreasePercent = val;
                _salaryIncreaseController.text = val.toStringAsFixed(1);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.shade200, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rate of Interest',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Fixed by EPFO',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_rateOfInterest.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
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
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$prefix${value.toStringAsFixed(suffix == '%' || suffix == ' Yr' ? (suffix == ' Yr' ? 0 : 1) : 0)}$suffix',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit, size: 16, color: Colors.teal.shade700),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.teal.shade600,
            inactiveTrackColor: Colors.teal.shade100,
            thumbColor: Colors.teal.shade700,
            overlayColor: Colors.teal.shade100,
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
              borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
            ),
            hintText:
                'Min: ${min.toStringAsFixed(0)}, Max: ${max.toStringAsFixed(0)}',
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
                    content: Text(
                      'Please enter a value between ${min.toStringAsFixed(0)} and ${max.toStringAsFixed(0)}',
                    ),
                    backgroundColor: Colors.red.shade400,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCards() {
    return Row(
      children: [
        Expanded(
          child: _buildResultCard(
            'Contribution',
            _totalContribution,
            Icons.account_balance_wallet_rounded,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildResultCard(
            'Interest',
            _totalInterest,
            Icons.trending_up_rounded,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildResultCard(
            'Maturity',
            _maturityAmount,
            Icons.account_balance_rounded,
            Colors.teal,
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 4),
          Text(
            formatToIndianUnits(amount),
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownChart() {
    double contributionPercentage =
        (_totalContribution / _maturityAmount) * 100;
    double interestPercentage = (_totalInterest / _maturityAmount) * 100;

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
            'Amount Breakdown',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: PieChartPainter(
                  contributionPercentage: contributionPercentage,
                  interestPercentage: interestPercentage,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                'Contribution',
                Colors.blue.shade600,
                contributionPercentage,
                _totalContribution,
              ),
              const SizedBox(width: 32),
              _buildLegendItem(
                'Interest',
                Colors.green.shade600,
                interestPercentage,
                _totalInterest,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    Color color,
    double percentage,
    double amount,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          formatToIndianUnits(amount),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
            'Year-wise EPF Growth',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'With ${_salaryIncreasePercent.toStringAsFixed(1)}% annual salary hike',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.teal.shade50),
              border: TableBorder.all(color: Colors.grey.shade300, width: 1),
              columnSpacing: 15,
              columns: const [
                DataColumn(
                  label: Text(
                    'Year',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Age',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Salary',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Contribution',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Interest',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Balance',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
              rows: breakdown.map((row) {
                bool isRetirementYear = row['age'] == _retirementAge;
                return DataRow(
                  color: isRetirementYear
                      ? WidgetStateProperty.all(Colors.teal.shade50)
                      : null,
                  cells: [
                    DataCell(
                      Text(
                        '${row['year']}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isRetirementYear
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${row['age']}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isRetirementYear
                              ? Colors.teal.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['salary']).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['contribution']).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['interest']).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['balance']).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isRetirementYear
                              ? Colors.teal.shade700
                              : Colors.grey.shade800,
                        ),
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

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.teal.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.teal.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'About EPF',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Employee Provident Fund (EPF) is a retirement benefits scheme where both employee and employer contribute equally towards the fund.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.teal.shade800,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.person,
                  'Employee contributes: ${_contributionPercent.toStringAsFixed(1)}%',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.business,
                  'Employer contributes: ${_contributionPercent.toStringAsFixed(1)}%',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.trending_up,
                  'Interest: ${_rateOfInterest.toStringAsFixed(2)}% p.a. (Compounded Annually)',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.verified_user,
                  'Tax benefits under Section 80C',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.lock_clock,
                  'Withdrawal at retirement (Age 58)',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.teal.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.teal.shade700),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _monthlySalaryController.dispose();
    _yourAgeController.dispose();
    _contributionController.dispose();
    _salaryIncreaseController.dispose();
    super.dispose();
  }
}

class PieChartPainter extends CustomPainter {
  final double contributionPercentage;
  final double interestPercentage;

  PieChartPainter({
    required this.contributionPercentage,
    required this.interestPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final contributionPaint = Paint()
      ..color = Colors.blue.shade600
      ..style = PaintingStyle.fill;

    final interestPaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.fill;

    final contributionAngle = (contributionPercentage / 100) * 2 * pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      contributionAngle,
      true,
      contributionPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + contributionAngle,
      (interestPercentage / 100) * 2 * pi,
      true,
      interestPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
