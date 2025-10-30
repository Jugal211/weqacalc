import 'package:flutter/material.dart';
import 'dart:math';
import 'package:weqacalc/utils/utils.dart';

class RetirementPlanningCalculator extends StatefulWidget {
  const RetirementPlanningCalculator({super.key});

  @override
  State<RetirementPlanningCalculator> createState() =>
      _RetirementPlanningCalculatorState();
}

class _RetirementPlanningCalculatorState
    extends State<RetirementPlanningCalculator> {
  final _currentAgeController = TextEditingController();
  final _retirementAgeController = TextEditingController();
  final _lifeExpectancyController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _inflationRateController = TextEditingController();
  final _preReturnController = TextEditingController();
  final _postReturnController = TextEditingController();
  final _existingFundController = TextEditingController();

  int _currentAge = 30;
  int _retirementAge = 60;
  int _lifeExpectancy = 85;
  double _monthlyIncome = 50000;
  double _inflationRate = 6;
  double _preRetirementReturn = 12;
  double _postRetirementReturn = 8;
  double _existingFund = 500000;

  // Calculated values
  double _corpusRequired = 0;
  double _monthlyInvestmentNeeded = 0;
  double _existingFundGrowth = 0;
  double _totalInvestmentNeeded = 0;
  int _yearsToRetirement = 0;
  int _retirementYears = 0;

  @override
  void initState() {
    super.initState();
    _currentAgeController.text = _currentAge.toString();
    _retirementAgeController.text = _retirementAge.toString();
    _lifeExpectancyController.text = _lifeExpectancy.toString();
    _monthlyIncomeController.text = _monthlyIncome.toStringAsFixed(0);
    _inflationRateController.text = _inflationRate.toStringAsFixed(1);
    _preReturnController.text = _preRetirementReturn.toStringAsFixed(1);
    _postReturnController.text = _postRetirementReturn.toStringAsFixed(1);
    _existingFundController.text = _existingFund.toStringAsFixed(0);
    _calculate();
  }

  void _calculate() {
    _yearsToRetirement = _retirementAge - _currentAge;
    _retirementYears = _lifeExpectancy - _retirementAge;

    if (_yearsToRetirement <= 0 || _retirementYears <= 0) {
      _corpusRequired = 0;
      _monthlyInvestmentNeeded = 0;
      _existingFundGrowth = 0;
      _totalInvestmentNeeded = 0;
      setState(() {});
      return;
    }

    // Calculate monthly income needed at retirement (adjusted for inflation)
    double monthlyIncomeAtRetirement =
        _monthlyIncome * pow(1 + _inflationRate / 100, _yearsToRetirement);

    // Calculate corpus required at retirement
    // Using present value of annuity formula considering post-retirement returns and inflation
    double realReturn = ((_postRetirementReturn - _inflationRate) / 100);
    double monthlyRealReturn = realReturn / 12;
    int totalMonths = _retirementYears * 12;

    if (monthlyRealReturn == 0) {
      _corpusRequired = monthlyIncomeAtRetirement * totalMonths;
    } else {
      _corpusRequired =
          monthlyIncomeAtRetirement *
          ((1 - pow(1 + monthlyRealReturn, -totalMonths)) / monthlyRealReturn);
    }

    // Calculate growth of existing fund
    _existingFundGrowth =
        _existingFund * pow(1 + _preRetirementReturn / 100, _yearsToRetirement);

    // Calculate additional corpus needed
    double additionalCorpusNeeded = _corpusRequired - _existingFundGrowth;

    if (additionalCorpusNeeded <= 0) {
      _monthlyInvestmentNeeded = 0;
      _totalInvestmentNeeded = 0;
    } else {
      // Calculate monthly investment needed using future value of annuity formula
      double monthlyRate = _preRetirementReturn / 12 / 100;
      int months = _yearsToRetirement * 12;

      if (monthlyRate == 0) {
        _monthlyInvestmentNeeded = additionalCorpusNeeded / months;
      } else {
        _monthlyInvestmentNeeded =
            additionalCorpusNeeded /
            (((pow(1 + monthlyRate, months) - 1) / monthlyRate) *
                (1 + monthlyRate));
      }

      _totalInvestmentNeeded = _monthlyInvestmentNeeded * months;
    }

    setState(() {});
  }

  List<Map<String, dynamic>> _getYearlyBreakdown() {
    List<Map<String, dynamic>> breakdown = [];
    double balance = _existingFund;
    double currentMonthlyIncome = _monthlyIncome;

    // Pre-retirement phase
    for (int year = 0; year < _yearsToRetirement; year++) {
      int age = _currentAge + year;
      double yearlyInvestment = _monthlyInvestmentNeeded * 12;
      double returns = balance * (_preRetirementReturn / 100);

      balance += yearlyInvestment + returns;
      currentMonthlyIncome = currentMonthlyIncome * (1 + _inflationRate / 100);

      breakdown.add({
        'year': year + 1,
        'age': age,
        'phase': 'Accumulation',
        'investment': yearlyInvestment,
        'returns': returns,
        'balance': balance,
        'withdrawal': 0.0,
        'monthlyIncome': currentMonthlyIncome,
      });
    }

    // Post-retirement phase
    for (int year = 0; year < min(_retirementYears, 30); year++) {
      int age = _retirementAge + year;
      double yearlyWithdrawal = currentMonthlyIncome * 12;
      double returns = balance * (_postRetirementReturn / 100);

      balance = balance + returns - yearlyWithdrawal;
      currentMonthlyIncome = currentMonthlyIncome * (1 + _inflationRate / 100);

      if (balance < 0) balance = 0;

      breakdown.add({
        'year': _yearsToRetirement + year + 1,
        'age': age,
        'phase': 'Withdrawal',
        'investment': 0.0,
        'returns': returns,
        'balance': balance,
        'withdrawal': yearlyWithdrawal,
        'monthlyIncome': currentMonthlyIncome,
      });
    }

    return breakdown;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retirement Planning'),
        backgroundColor: Colors.deepPurple.shade600,
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
                  _buildResultsCard(),
                  const SizedBox(height: 20),
                  _buildBreakdownCard(),
                  const SizedBox(height: 20),
                  _buildYearlyTable(),
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
          colors: [Colors.deepPurple.shade600, Colors.deepPurple.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.elderly_rounded, size: 70, color: Colors.white),
          const SizedBox(height: 16),
          const Text(
            'Retirement Planning Calculator',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Plan your golden years with confidence',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
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
            'Input Details',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Current Age',
            value: _currentAge.toDouble(),
            min: 18,
            max: 65,
            divisions: 47,
            suffix: ' Years',
            controller: _currentAgeController,
            onChanged: (val) {
              setState(() {
                _currentAge = val.toInt();
                _currentAgeController.text = val.toInt().toString();
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Desired Retirement Age',
            value: _retirementAge.toDouble(),
            min: max(_currentAge + 1, 40).toDouble(),
            max: 75,
            divisions: max(1, 75 - max(_currentAge + 1, 40)),
            suffix: ' Years',
            controller: _retirementAgeController,
            onChanged: (val) {
              setState(() {
                _retirementAge = val.toInt();
                _retirementAgeController.text = val.toInt().toString();
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Life Expectancy',
            value: _lifeExpectancy.toDouble(),
            min: max(_retirementAge + 1, 65).toDouble(),
            max: 100,
            divisions: max(1, 100 - max(_retirementAge + 1, 65)),
            suffix: ' Years',
            controller: _lifeExpectancyController,
            onChanged: (val) {
              setState(() {
                _lifeExpectancy = val.toInt();
                _lifeExpectancyController.text = val.toInt().toString();
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Monthly Income Required in Retirement',
            value: _monthlyIncome,
            min: 10000,
            max: 500000,
            divisions: 490,
            prefix: '₹',
            controller: _monthlyIncomeController,
            onChanged: (val) {
              setState(() {
                _monthlyIncome = val;
                _monthlyIncomeController.text = val.toStringAsFixed(0);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Expected Inflation Rate',
            value: _inflationRate,
            min: 2,
            max: 15,
            divisions: 130,
            suffix: '%',
            controller: _inflationRateController,
            onChanged: (val) {
              setState(() {
                _inflationRate = val;
                _inflationRateController.text = val.toStringAsFixed(1);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Expected Return (Pre-retirement)',
            value: _preRetirementReturn,
            min: 4,
            max: 20,
            divisions: 160,
            suffix: '%',
            controller: _preReturnController,
            onChanged: (val) {
              setState(() {
                _preRetirementReturn = val;
                _preReturnController.text = val.toStringAsFixed(1);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Expected Return (Post-retirement)',
            value: _postRetirementReturn,
            min: 3,
            max: 15,
            divisions: 120,
            suffix: '%',
            controller: _postReturnController,
            onChanged: (val) {
              setState(() {
                _postRetirementReturn = val;
                _postReturnController.text = val.toStringAsFixed(1);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Existing Retirement Fund',
            value: _existingFund,
            min: 0,
            max: 10000000,
            divisions: 1000,
            prefix: '₹',
            controller: _existingFundController,
            onChanged: (val) {
              setState(() {
                _existingFund = val;
                _existingFundController.text = val.toStringAsFixed(0);
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
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.deepPurple.shade200,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$prefix${value.toStringAsFixed(suffix == '%' || suffix.contains('Year') ? (suffix.contains('Year') ? 0 : 1) : 0)}$suffix',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.deepPurple.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.edit,
                      size: 16,
                      color: Colors.deepPurple.shade700,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.deepPurple.shade600,
            inactiveTrackColor: Colors.deepPurple.shade100,
            thumbColor: Colors.deepPurple.shade700,
            overlayColor: Colors.deepPurple.shade100,
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
              borderSide: BorderSide(
                color: Colors.deepPurple.shade600,
                width: 2,
              ),
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
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsCard() {
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
            'Results',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildResultRow(
            'Retirement Corpus Required',
            formatToIndianUnits(_corpusRequired),
            Colors.deepPurple,
            Icons.account_balance,
          ),
          const SizedBox(height: 16),
          _buildResultRow(
            'Existing Fund Growth',
            formatToIndianUnits(_existingFundGrowth),
            Colors.green,
            Icons.trending_up,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildResultRow(
            'Monthly Investment Needed',
            '₹${_monthlyInvestmentNeeded.toStringAsFixed(0)}',
            Colors.orange,
            Icons.savings,
            isHighlight: true,
          ),
          const SizedBox(height: 16),
          _buildResultRow(
            'Total Investment Needed',
            formatToIndianUnits(_totalInvestmentNeeded),
            Colors.blue,
            Icons.account_balance_wallet,
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(
    String label,
    String value,
    Color color,
    IconData icon, {
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? color.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isHighlight ? Border.all(color: color, width: 2) : null,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
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
                    fontSize: isHighlight ? 22 : 18,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard() {
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
            'Planning Summary',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            'Years to Retirement',
            '$_yearsToRetirement years',
            Icons.work,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Retirement Duration',
            '$_retirementYears years',
            Icons.elderly,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Pre-retirement Returns',
            '${_preRetirementReturn.toStringAsFixed(1)}% p.a.',
            Icons.trending_up,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            'Post-retirement Returns',
            '${_postRetirementReturn.toStringAsFixed(1)}% p.a.',
            Icons.trending_down,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.deepPurple.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.deepPurple.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildYearlyTable() {
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
            'Year-wise Projection',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'First 30 years shown',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                Colors.deepPurple.shade50,
              ),
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
                    'Phase',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Investment',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Returns',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Withdrawal',
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
              rows: breakdown.take(30).map((row) {
                bool isRetirementYear = row['age'] == _retirementAge;
                return DataRow(
                  color: isRetirementYear
                      ? WidgetStateProperty.all(Colors.orange.shade50)
                      : null,
                  cells: [
                    DataCell(
                      Text(
                        '${row['year']}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                    DataCell(
                      Text(
                        '${row['age']}',
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
                        '${row['phase']}',
                        style: TextStyle(
                          fontSize: 10,
                          color: row['phase'] == 'Accumulation'
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['investment']).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['returns']).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['withdrawal']).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['balance'] / 100000).toStringAsFixed(1)}L',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
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

  @override
  void dispose() {
    _currentAgeController.dispose();
    _retirementAgeController.dispose();
    _lifeExpectancyController.dispose();
    _monthlyIncomeController.dispose();
    _inflationRateController.dispose();
    _preReturnController.dispose();
    _postReturnController.dispose();
    _existingFundController.dispose();
    super.dispose();
  }
}
