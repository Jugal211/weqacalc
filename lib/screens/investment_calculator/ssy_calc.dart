import 'package:flutter/material.dart';
import 'dart:math';

class SSYCalculator extends StatefulWidget {
  const SSYCalculator({super.key});

  @override
  State<SSYCalculator> createState() => _SSYCalculatorState();
}

class _SSYCalculatorState extends State<SSYCalculator> {
  final _yearlyInvestmentController = TextEditingController();
  final _girlAgeController = TextEditingController();
  final _startYearController = TextEditingController();

  double _yearlyInvestment = 100000;
  int _girlAge = 5;
  int _startYear = 2024;
  final double _rate = 8.2; // Fixed rate

  double _totalInvestment = 0;
  double _totalInterest = 0;
  double _maturityAmount = 0;
  int _maturityYear = 0;
  int _depositYears = 15;
  int _totalTenure = 21;

  @override
  void initState() {
    super.initState();
    _yearlyInvestmentController.text = _yearlyInvestment.toStringAsFixed(0);
    _girlAgeController.text = _girlAge.toString();
    _startYearController.text = _startYear.toString();
    _calculate();
  }

  void _calculate() {
    // SSY: Deposit for 15 years, account matures after 21 years from opening
    _depositYears = 15;
    _totalTenure = 21; // Fixed 21 years tenure
    _maturityYear = _startYear + _totalTenure;

    double r = _rate / 100;

    // Calculate maturity amount
    // For first 15 years: Annual deposits with compound interest
    double balance = 0;

    // Investment phase (15 years)
    for (int year = 1; year <= _depositYears; year++) {
      balance += _yearlyInvestment;
      balance = balance * (1 + r);
    }

    // After 15 years, only interest compounds for remaining 6 years (no deposits)
    int remainingYears = _totalTenure - _depositYears; // 21 - 15 = 6 years
    if (remainingYears > 0) {
      balance = balance * pow(1 + r, remainingYears);
    }

    _maturityAmount = balance;
    _totalInvestment = _yearlyInvestment * _depositYears;
    _totalInterest = _maturityAmount - _totalInvestment;

    setState(() {});
  }

  List<Map<String, dynamic>> _getYearlyBreakdown() {
    List<Map<String, dynamic>> breakdown = [];
    double r = _rate / 100;
    double balance = 0;

    for (int year = 0; year <= _totalTenure; year++) {
      int girlCurrentAge = _girlAge + year;
      int currentYear = _startYear + year;
      double deposit = 0;
      double interest = 0;

      if (year == 0) {
        breakdown.add({
          'year': year,
          'calendarYear': currentYear,
          'girlAge': girlCurrentAge,
          'deposit': 0.0,
          'interest': 0.0,
          'balance': 0.0,
        });
        continue;
      }

      // Deposits only for first 15 years
      if (year <= _depositYears) {
        deposit = _yearlyInvestment;
        balance += deposit;
      }

      // Interest compounds every year
      interest = balance * r;
      balance += interest;

      breakdown.add({
        'year': year,
        'calendarYear': currentYear,
        'girlAge': girlCurrentAge,
        'deposit': deposit,
        'interest': interest,
        'balance': balance,
      });
    }

    return breakdown;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSY Calculator'),
        backgroundColor: Colors.pink.shade600,
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
                  _buildTimelineCard(),
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
          colors: [Colors.pink.shade600, Colors.pink.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.girl_rounded, size: 70, color: Colors.white),
          const SizedBox(height: 20),
          const Text(
            'Maturity Amount',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
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
            'after $_totalTenure years (Year $_maturityYear)',
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
            'SSY Account Details',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Yearly Investment',
            value: _yearlyInvestment,
            min: 250,
            max: 150000,
            divisions: 299,
            prefix: '₹',
            controller: _yearlyInvestmentController,
            onChanged: (val) {
              setState(() {
                _yearlyInvestment = val;
                _yearlyInvestmentController.text = val.toStringAsFixed(0);
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
                    'Max: ₹1,50,000/year, Min: ₹250/year',
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
            label: 'Girl\'s Current Age',
            value: _girlAge.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            suffix: ' Years',
            controller: _girlAgeController,
            onChanged: (val) {
              setState(() {
                _girlAge = val.toInt();
                _girlAgeController.text = val.toInt().toString();
                _calculate();
              });
            },
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.child_care, size: 20, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Account can only be opened for girls aged 1-10 years',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Account Start Year',
            value: _startYear.toDouble(),
            min: 2018,
            max: 2030,
            divisions: 12,
            suffix: '',
            controller: _startYearController,
            onChanged: (val) {
              setState(() {
                _startYear = val.toInt();
                _startYearController.text = val.toInt().toString();
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
                Icon(
                  Icons.calendar_month,
                  size: 20,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Account opened in $_startYear - Matures in $_maturityYear',
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.pink.shade200, width: 2),
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
                      'Fixed by Government',
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
                    color: Colors.pink.shade600,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${_rate.toStringAsFixed(1)}%',
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
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.pink.shade200, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$prefix${value.toStringAsFixed(0)}$suffix',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.pink.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit, size: 16, color: Colors.pink.shade700),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.pink.shade600,
            inactiveTrackColor: Colors.pink.shade100,
            thumbColor: Colors.pink.shade700,
            overlayColor: Colors.pink.shade100,
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: (val) {
              controller.text = val.toStringAsFixed(0);
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
              borderSide: BorderSide(color: Colors.pink.shade600, width: 2),
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
              backgroundColor: Colors.pink.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard() {
    // Calculate maturity age dynamically
    final int maturityAge = _girlAge + _totalTenure;
    final int depositEndYear = _startYear + _depositYears - 1;
    final int growthYears = _totalTenure - _depositYears;

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
            'Account Timeline',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildTimelineItem(
            'Start Year',
            '$_startYear',
            'Girl is $_girlAge years old',
            Colors.blue,
            Icons.calendar_today,
          ),
          _buildTimelineConnector(),
          _buildTimelineItem(
            'Deposit Phase',
            '$_depositYears years',
            '$_startYear - $depositEndYear',
            Colors.green,
            Icons.account_balance_wallet,
          ),
          _buildTimelineConnector(),
          _buildTimelineItem(
            'Growth Phase',
            '$growthYears years',
            'Only interest compounds',
            Colors.orange,
            Icons.trending_up,
          ),
          _buildTimelineConnector(),
          _buildTimelineItem(
            'Maturity',
            'Year $_maturityYear',
            'Girl turns $maturityAge years old',
            Colors.pink,
            Icons.celebration,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(child: Icon(icon, color: color, size: 24)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineConnector() {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
      child: Container(width: 2, height: 30, color: Colors.grey.shade300),
    );
  }

  Widget _buildResultCards() {
    return Row(
      children: [
        Expanded(
          child: _buildResultCard(
            'Invested',
            _totalInvestment,
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
            Colors.pink,
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
            '₹${(amount / 100000).toStringAsFixed(1)}L',
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
    double investmentPercentage = (_totalInvestment / _maturityAmount) * 100;
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
                  investmentPercentage: investmentPercentage,
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
                'Invested',
                Colors.blue.shade600,
                investmentPercentage,
                _totalInvestment,
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
          '₹${(amount / 100000).toStringAsFixed(1)}L',
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
            'Year-wise SSY Growth',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Deposits for 15 years, interest till maturity',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.pink.shade50),
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
                    'Calendar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Girl Age',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Deposit',
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
                bool isMaturityYear = row['girlAge'] == 21;
                bool isDepositPhase =
                    row['year'] <= _depositYears && row['year'] > 0;
                return DataRow(
                  color: isMaturityYear
                      ? WidgetStateProperty.all(Colors.pink.shade50)
                      : null,
                  cells: [
                    DataCell(
                      Text(
                        '${row['year']}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isMaturityYear
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${row['calendarYear']}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${row['girlAge']}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isMaturityYear
                              ? Colors.pink.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['deposit']).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDepositPhase
                              ? Colors.blue.shade700
                              : Colors.grey.shade400,
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
                          color: isMaturityYear
                              ? Colors.pink.shade700
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
          colors: [Colors.pink.shade50, Colors.pink.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.pink.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.pink.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'About Sukanya Samriddhi Yojana',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Sukanya Samriddhi Yojana (SSY) is a government-backed savings scheme for girl child under "Beti Bachao, Beti Padhao" campaign. It offers highest interest rate with tax benefits.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.pink.shade800,
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
                _buildInfoRow(Icons.girl, 'For girl child aged 1-10 years'),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.account_balance_wallet,
                  'Min: ₹250/year, Max: ₹1,50,000/year',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.calendar_today, 'Deposit for 15 years'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.lock_clock, 'Matures when girl turns 21'),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.trending_up,
                  'Interest: ${_rate.toStringAsFixed(1)}% p.a. (Compounded Annually)',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.verified_user,
                  'Tax-Free Returns (EEE status)',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.money_off,
                  'Partial withdrawal allowed after 18',
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
        Icon(icon, size: 18, color: Colors.pink.shade700),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.pink.shade700),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _yearlyInvestmentController.dispose();
    _girlAgeController.dispose();
    _startYearController.dispose();
    super.dispose();
  }
}

class PieChartPainter extends CustomPainter {
  final double investmentPercentage;
  final double interestPercentage;

  PieChartPainter({
    required this.investmentPercentage,
    required this.interestPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final investmentPaint = Paint()
      ..color = Colors.blue.shade600
      ..style = PaintingStyle.fill;

    final interestPaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.fill;

    final investmentAngle = (investmentPercentage / 100) * 2 * pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      investmentAngle,
      true,
      investmentPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + investmentAngle,
      (interestPercentage / 100) * 2 * pi,
      true,
      interestPaint,
    );

    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.6, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
