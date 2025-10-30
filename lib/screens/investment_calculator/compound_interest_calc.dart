import 'package:flutter/material.dart';
import 'dart:math';
import 'package:weqacalc/utils/utils.dart';

class CompoundInterestCalculator extends StatefulWidget {
  const CompoundInterestCalculator({super.key});

  @override
  State<CompoundInterestCalculator> createState() =>
      _CompoundInterestCalculatorState();
}

class _CompoundInterestCalculatorState
    extends State<CompoundInterestCalculator> {
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _timeController = TextEditingController();

  double _principal = 100000;
  double _rate = 8;
  double _time = 5;
  String _compoundingFrequency = 'Yearly';

  double _maturityAmount = 0;
  double _totalInterest = 0;
  int _compoundingPeriods = 0;

  final List<Map<String, dynamic>> _frequencies = [
    {'label': 'Yearly', 'value': 1, 'description': 'Once per year'},
    {'label': 'Half-Yearly', 'value': 2, 'description': 'Twice per year'},
    {'label': 'Quarterly', 'value': 4, 'description': 'Four times per year'},
    {'label': 'Monthly', 'value': 12, 'description': '12 times per year'},
    {'label': 'Weekly', 'value': 52, 'description': '52 times per year'},
    {'label': 'Daily', 'value': 365, 'description': '365 times per year'},
  ];

  @override
  void initState() {
    super.initState();
    _principalController.text = _principal.toStringAsFixed(0);
    _rateController.text = _rate.toStringAsFixed(1);
    _timeController.text = _time.toStringAsFixed(1);
    _calculate();
  }

  void _calculate() {
    int n = _frequencies.firstWhere(
      (f) => f['label'] == _compoundingFrequency,
    )['value'];
    double r = _rate / 100;
    double t = _time;

    _maturityAmount = _principal * pow(1 + r / n, n * t);
    _totalInterest = _maturityAmount - _principal;
    _compoundingPeriods = (n * t).toInt();

    setState(() {});
  }

  List<Map<String, dynamic>> _getYearlyBreakdown() {
    List<Map<String, dynamic>> breakdown = [];
    int n = _frequencies.firstWhere(
      (f) => f['label'] == _compoundingFrequency,
    )['value'];
    double r = _rate / 100;

    for (int year = 0; year <= _time.ceil(); year++) {
      double amount = _principal * pow(1 + r / n, n * year);
      double interest = amount - _principal;
      double yearlyInterest = 0;

      if (year > 0) {
        double prevAmount = _principal * pow(1 + r / n, n * (year - 1));
        yearlyInterest = amount - prevAmount;
      }

      breakdown.add({
        'year': year,
        'amount': amount,
        'totalInterest': interest,
        'yearlyInterest': yearlyInterest,
      });
    }

    return breakdown;
  }

  Map<String, double> _compareFrequencies() {
    Map<String, double> comparison = {};
    double r = _rate / 100;
    double t = _time;

    for (var freq in _frequencies) {
      int n = freq['value'];
      double amount = _principal * pow(1 + r / n, n * t);
      comparison[freq['label']] = amount;
    }

    return comparison;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compound Interest'),
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
                  _buildFrequencySelector(),
                  const SizedBox(height: 20),
                  _buildResultCards(),
                  const SizedBox(height: 20),
                  _buildBreakdownChart(),
                  const SizedBox(height: 20),
                  _buildFrequencyComparison(),
                  const SizedBox(height: 20),
                  _buildYearlyBreakdown(),
                  const SizedBox(height: 20),
                  _buildFormulaCard(),
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
            Icons.account_balance_rounded,
            size: 70,
            color: Colors.white,
          ),
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
            'after ${_time.toStringAsFixed(1)} years',
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
            'Investment Details',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Principal Amount',
            value: _principal,
            min: 1000,
            max: 10000000,
            divisions: 1000,
            prefix: '₹',
            controller: _principalController,
            onChanged: (val) {
              setState(() {
                _principal = val;
                _principalController.text = val.toStringAsFixed(0);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Rate of Interest (% p.a.)',
            value: _rate,
            min: 1,
            max: 30,
            divisions: 290,
            suffix: '%',
            controller: _rateController,
            onChanged: (val) {
              setState(() {
                _rate = val;
                _rateController.text = val.toStringAsFixed(1);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Time Period',
            value: _time,
            min: 0.5,
            max: 50,
            divisions: 99,
            suffix: ' Years',
            controller: _timeController,
            onChanged: (val) {
              setState(() {
                _time = val;
                _timeController.text = val.toStringAsFixed(1);
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
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.shade200, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$prefix${value.toStringAsFixed(suffix == '%' || suffix.contains('Year') ? 1 : 0)}$suffix',
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
              controller.text = val.toStringAsFixed(
                suffix == '%' || suffix.contains('Year') ? 1 : 0,
              );
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
            hintText: 'Enter value',
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
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencySelector() {
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
            'Compounding Frequency',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'How often interest is calculated and added',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _frequencies.map((freq) {
              bool isSelected = _compoundingFrequency == freq['label'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _compoundingFrequency = freq['label'];
                    _calculate();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.teal.shade600
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.teal.shade600
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        freq['label'],
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        freq['description'],
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected
                              ? Colors.white70
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: Colors.teal.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Interest will compound $_compoundingPeriods times over ${_time.toStringAsFixed(1)} years',
                    style: TextStyle(fontSize: 12, color: Colors.teal.shade700),
                  ),
                ),
              ],
            ),
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
            'Principal',
            _principal,
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
    double principalPercentage = (_principal / _maturityAmount) * 100;
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
                  principalPercentage: principalPercentage,
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
                'Principal',
                Colors.blue.shade600,
                principalPercentage,
                _principal,
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

  Widget _buildFrequencyComparison() {
    final comparison = _compareFrequencies();
    final maxValue = comparison.values.reduce(max);
    final minValue = comparison.values.reduce(min);
    final difference = maxValue - minValue;

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
            'Compare Frequencies',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'See how different frequencies affect returns',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          ...comparison.entries.map((entry) {
            bool isSelected = entry.key == _compoundingFrequency;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: isSelected
                              ? Colors.teal.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        '₹${entry.value.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.teal.shade700
                              : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value:
                        (entry.value - _principal) /
                        (_maturityAmount - _principal),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isSelected ? Colors.teal.shade600 : Colors.grey.shade400,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Daily compounding earns ₹${difference.toStringAsFixed(0)} more than yearly!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w600,
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
            'Year-wise Growth',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Compounded $_compoundingFrequency',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.teal.shade50),
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
                    'Amount',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Yearly Interest',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Interest',
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
                        '₹${(row['amount']).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['yearlyInterest']).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['totalInterest']).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.teal.shade700,
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

  Widget _buildFormulaCard() {
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
                Icons.calculate_rounded,
                color: Colors.teal.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Compound Interest Formula',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A = P(1 + r/n)^(nt)',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.teal.shade700,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
                _buildFormulaRow('A', 'Maturity Amount (Final Value)'),
                _buildFormulaRow('P', 'Principal Amount (Initial)'),
                _buildFormulaRow('r', 'Annual Interest Rate'),
                _buildFormulaRow('n', 'Compounding Frequency'),
                _buildFormulaRow('t', 'Time Period (years)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaRow(String symbol, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: Colors.teal.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _principalController.dispose();
    _rateController.dispose();
    _timeController.dispose();
    super.dispose();
  }
}

class PieChartPainter extends CustomPainter {
  final double principalPercentage;
  final double interestPercentage;

  PieChartPainter({
    required this.principalPercentage,
    required this.interestPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final principalPaint = Paint()
      ..color = Colors.blue.shade600
      ..style = PaintingStyle.fill;

    final interestPaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.fill;

    final principalAngle = (principalPercentage / 100) * 2 * pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      principalAngle,
      true,
      principalPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + principalAngle,
      (interestPercentage / 100) * 2 * pi,
      true,
      interestPaint,
    );

    // Inner white circle for donut effect
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.6, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
