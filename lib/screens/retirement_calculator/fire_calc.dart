import 'package:flutter/material.dart';
import 'dart:math';

class FIRECalculator extends StatefulWidget {
  const FIRECalculator({super.key});

  @override
  State<FIRECalculator> createState() => _FIRECalculatorState();
}

class _FIRECalculatorState extends State<FIRECalculator> {
  final _monthlyExpenseController = TextEditingController();
  final _currentAgeController = TextEditingController();
  final _retirementAgeController = TextEditingController();
  final _inflationRateController = TextEditingController();
  final _coastFIREAgeController = TextEditingController();

  double _monthlyExpense = 50000;
  int _currentAge = 25;
  int _retirementAge = 40;
  double _inflationRate = 10;
  int _coastFIREAge = 30;

  // Calculated values
  double _expenseToday = 0;
  double _expenseAtRetirement = 0;
  double _leanFIRE = 0;
  double _traditionalFIRE = 0;
  double _fatFIRE = 0;
  double _coastFIRE = 0;

  @override
  void initState() {
    super.initState();
    _monthlyExpenseController.text = _monthlyExpense.toStringAsFixed(0);
    _currentAgeController.text = _currentAge.toString();
    _retirementAgeController.text = _retirementAge.toString();
    _inflationRateController.text = _inflationRate.toStringAsFixed(0);
    _coastFIREAgeController.text = _coastFIREAge.toString();
    _calculate();
  }

  void _calculate() {
    // Ensure coast FIRE age is valid
    if (_coastFIREAge <= _currentAge) {
      _coastFIREAge = _currentAge + 1;
    }
    if (_coastFIREAge > 50) {
      _coastFIREAge = 50;
    }

    // Ensure retirement age is greater than current age
    if (_retirementAge <= _currentAge) {
      _retirementAge = _currentAge + 1;
    }

    // Annual expense today
    _expenseToday = _monthlyExpense * 12;

    // Years to retirement
    int yearsToRetirement = _retirementAge - _currentAge;

    // Expense at retirement (adjusted for inflation)
    _expenseAtRetirement =
        _expenseToday * pow(1 + _inflationRate / 100, yearsToRetirement);

    // Lean FIRE: 25 times annual expenses with 3.5% withdrawal rate
    _leanFIRE = _expenseAtRetirement / 0.035;

    // Traditional FIRE: 25-30 times annual expenses with 3.5% withdrawal rate
    _traditionalFIRE = _expenseAtRetirement / 0.035;

    // Fat FIRE: 30-35 times annual expenses with more cushion
    _fatFIRE = _expenseAtRetirement / 0.03;

    // Coast FIRE: Corpus needed at coast age that will grow to retirement
    if (_coastFIREAge > _currentAge && _coastFIREAge < _retirementAge) {
      int coastYears = _coastFIREAge - _currentAge;
      int growthYears = _retirementAge - _coastFIREAge;
      double expenseAtCoastAge =
          _expenseToday * pow(1 + _inflationRate / 100, coastYears);
      double requiredAtRetirement =
          expenseAtCoastAge *
          pow(1 + _inflationRate / 100, growthYears) /
          0.035;
      // Assuming 12% annual return on investments
      _coastFIRE = requiredAtRetirement / pow(1.12, growthYears);
    } else if (_coastFIREAge >= _retirementAge) {
      _coastFIRE = _traditionalFIRE;
    } else {
      _coastFIRE = 0;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FIRE Calculator'),
        backgroundColor: Colors.orange.shade700,
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
                  _buildOutputCard(),
                  const SizedBox(height: 20),
                  _buildFIRETypesInfo(),
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
          colors: [Colors.orange.shade700, Colors.orange.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            size: 70,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          const Text(
            'FIRE Calculator',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Financial Independence Retire Early',
            style: TextStyle(color: Colors.white70, fontSize: 16),
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
            'Input Fields',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Monthly Expense',
            value: _monthlyExpense,
            min: 10000,
            max: 500000,
            divisions: 490,
            prefix: '₹',
            controller: _monthlyExpenseController,
            onChanged: (val) {
              setState(() {
                _monthlyExpense = val;
                _monthlyExpenseController.text = val.toStringAsFixed(0);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Current Age',
            value: _currentAge.toDouble(),
            min: 18,
            max: 50,
            divisions: 32,
            suffix: '',
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
            label: 'Retirement Age',
            value: _retirementAge.toDouble(),
            min: 30,
            max: 65,
            divisions: 35,
            suffix: '',
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
            label: 'Assumed Inflation Rate',
            value: _inflationRate,
            min: 0,
            max: 15,
            divisions: 120,
            suffix: '',
            controller: _inflationRateController,
            onChanged: (val) {
              setState(() {
                _inflationRate = val;
                _inflationRateController.text = val.toStringAsFixed(0);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Desired Coast FIRE Age',
            value: _coastFIREAge.toDouble(),
            min: 18,
            max: 50,
            divisions: 32,
            suffix: '',
            controller: _coastFIREAgeController,
            onChanged: (val) {
              setState(() {
                // Prevent invalid coast age
                if (val <= _currentAge) {
                  val = (_currentAge + 1).toDouble();
                }
                if (val > 50) val = 50;
                _coastFIREAge = val.toInt();
                _coastFIREAgeController.text = val.toInt().toString();
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
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$prefix${value.toStringAsFixed(0)}$suffix',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
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
            activeTrackColor: Colors.orange.shade600,
            inactiveTrackColor: Colors.orange.shade100,
            thumbColor: Colors.orange.shade700,
            overlayColor: Colors.orange.shade100,
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
              borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
            ),
            hintText: 'Value',
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
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputCard() {
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
            'Output',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildOutputItem(
                  'Expense Today',
                  '₹${_expenseToday.toStringAsFixed(0)}',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOutputItem(
                  'Expense at $_retirementAge',
                  '₹${_expenseAtRetirement.toStringAsFixed(0)}',
                  Colors.purple,
                  showInfo: true,
                  infoText:
                      'Adjusted for ${_inflationRate.toStringAsFixed(0)}% inflation over ${_retirementAge - _currentAge} years',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildFIREOutput(
                  'Lean FIRE',
                  '₹${(_leanFIRE / 10000000).toStringAsFixed(2)} Cr',
                  Colors.green,
                  '3.5% withdrawal rate',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFIREOutput(
                  'FIRE',
                  '₹${(_traditionalFIRE / 10000000).toStringAsFixed(2)} Cr',
                  Colors.orange,
                  '3.5% withdrawal rate',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFIREOutput(
                  'Fat FIRE',
                  '₹${(_fatFIRE / 10000000).toStringAsFixed(2)} Cr',
                  Colors.red,
                  '3% withdrawal rate',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFIREOutput(
                  'Coast FIRE',
                  '₹${(_coastFIRE / 10000000).toStringAsFixed(2)} Cr',
                  Colors.teal,
                  'By age $_coastFIREAge',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOutputItem(
    String label,
    String value,
    Color color, {
    bool showInfo = false,
    String infoText = '',
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (showInfo)
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(infoText),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFIREOutput(
    String label,
    String value,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildFIRETypesInfo() {
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
            'Understanding FIRE Types',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildFIRETypeCard(
            '🔥 Traditional FIRE',
            'Most stringent approach with 50-70% savings rate',
            [
              '• 25-30x annual expenses corpus',
              '• 3.5% safe withdrawal rate for India',
              '• Covers all living costs through passive income',
              '• Requires significant sacrifice during earning years',
            ],
            Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildFIRETypeCard(
            '🌱 Lean FIRE',
            'Minimalist lifestyle with smaller corpus',
            [
              '• Modest budget, cutting to bare minimum',
              '• Living in affordable Tier 2/3 cities',
              '• Focus on experiences over possessions',
              '• Geographic arbitrage strategy',
            ],
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildFIRETypeCard(
            '💎 Fat FIRE',
            'Retire without compromising luxury',
            [
              '• Substantial corpus for high spending',
              '• ₹15-40 crore or more corpus',
              '• International travel, premium healthcare',
              '• Requires high income & aggressive saving',
            ],
            Colors.red,
          ),
          const SizedBox(height: 16),
          _buildFIRETypeCard(
            '☕ Barista FIRE',
            'Semi-retirement with part-time work',
            [
              '• Partial financial independence',
              '• Part-time work covers remaining expenses',
              '• Better work-life balance',
              '• Investments continue growing',
            ],
            Colors.brown,
          ),
          const SizedBox(height: 16),
          _buildFIRETypeCard(
            '🏖️ Coast FIRE',
            'Front-load savings, then coast',
            [
              '• Save aggressively early in career',
              '• Let compound interest work its magic',
              '• Only earn for current living expenses',
              '• Downshift to less stressful job',
            ],
            Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildFIRETypeCard(
    String title,
    String description,
    List<String> points,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          ...points.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                point,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade800,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _monthlyExpenseController.dispose();
    _currentAgeController.dispose();
    _retirementAgeController.dispose();
    _inflationRateController.dispose();
    _coastFIREAgeController.dispose();
    super.dispose();
  }
}
