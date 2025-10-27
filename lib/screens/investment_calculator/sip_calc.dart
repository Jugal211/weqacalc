import 'package:flutter/material.dart';
import 'dart:math';

class SIPCalculator extends StatefulWidget {
  const SIPCalculator({super.key});

  @override
  State<SIPCalculator> createState() => _SIPCalculatorState();
}

class _SIPCalculatorState extends State<SIPCalculator> {
  final _monthlyInvestmentController = TextEditingController();
  final _expectedReturnController = TextEditingController();
  final _timePeriodController = TextEditingController();
  final _stepUpController = TextEditingController();

  double _monthlyInvestment = 10000;
  double _expectedReturn = 12;
  int _timePeriod = 10;
  double _stepUpPercentage = 0;

  double _totalInvestment = 0;
  double _estimatedReturns = 0;
  double _totalValue = 0;

  @override
  void initState() {
    super.initState();
    _monthlyInvestmentController.text = _monthlyInvestment.toStringAsFixed(0);
    _expectedReturnController.text = _expectedReturn.toStringAsFixed(1);
    _timePeriodController.text = _timePeriod.toString();
    _stepUpController.text = _stepUpPercentage.toStringAsFixed(1);
    _calculate();
  }

  void _calculate() {
    if (_stepUpPercentage == 0) {
      _calculateRegularSIP();
    } else {
      _calculateStepUpSIP();
    }
    setState(() {});
  }

  void _calculateRegularSIP() {
    double monthlyRate = _expectedReturn / 12 / 100;
    int months = _timePeriod * 12;

    // Future Value of SIP formula: FV = P * [((1 + r)^n - 1) / r] * (1 + r)
    if (monthlyRate == 0) {
      _totalValue = _monthlyInvestment * months;
    } else {
      _totalValue =
          _monthlyInvestment *
          (pow(1 + monthlyRate, months) - 1) /
          monthlyRate *
          (1 + monthlyRate);
    }

    _totalInvestment = _monthlyInvestment * months;
    _estimatedReturns = _totalValue - _totalInvestment;
  }

  void _calculateStepUpSIP() {
    double monthlyRate = _expectedReturn / 12 / 100;
    int months = _timePeriod * 12;
    double currentSIP = _monthlyInvestment;

    _totalInvestment = 0;
    _totalValue = 0;

    for (int month = 1; month <= months; month++) {
      // Apply step-up at the beginning of each year (except first year)
      if (month > 1 && (month - 1) % 12 == 0) {
        currentSIP = currentSIP * (1 + _stepUpPercentage / 100);
      }

      _totalInvestment += currentSIP;

      // Calculate future value of this investment
      int remainingMonths = months - month + 1;
      double futureValue = currentSIP * pow(1 + monthlyRate, remainingMonths);
      _totalValue += futureValue;
    }

    _estimatedReturns = _totalValue - _totalInvestment;
  }

  List<Map<String, dynamic>> _getYearlyBreakdown() {
    List<Map<String, dynamic>> breakdown = [];
    double monthlyRate = _expectedReturn / 12 / 100;
    double currentSIP = _monthlyInvestment;
    double cumulativeInvestment = 0;
    double cumulativeValue = 0;

    for (int year = 1; year <= _timePeriod; year++) {
      double yearlyInvestment = 0;
      double yearStartValue = cumulativeValue;

      // Apply step-up at the beginning of each year (except first year)
      if (year > 1) {
        currentSIP = currentSIP * (1 + _stepUpPercentage / 100);
      }

      // Calculate for each month in the year
      for (int month = 1; month <= 12; month++) {
        yearlyInvestment += currentSIP;
        cumulativeInvestment += currentSIP;

        // Add returns on existing value
        cumulativeValue = (cumulativeValue + currentSIP) * (1 + monthlyRate);
      }

      double yearEndValue = cumulativeValue;
      double yearlyReturns = yearEndValue - yearStartValue - yearlyInvestment;

      breakdown.add({
        'year': year,
        'sip': currentSIP,
        'yearlyInvestment': yearlyInvestment,
        'yearlyReturns': yearlyReturns,
        'totalInvestment': cumulativeInvestment,
        'totalValue': yearEndValue,
      });
    }

    return breakdown;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SIP Calculator'),
        backgroundColor: Colors.orange.shade600,
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
                  _buildSummaryCards(),
                  const SizedBox(height: 20),
                  _buildBreakdownChart(),
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
          colors: [Colors.orange.shade600, Colors.orange.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.savings_rounded, size: 70, color: Colors.white),
          const SizedBox(height: 20),
          const Text(
            'Total Value',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_totalValue.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'after $_timePeriod years',
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
            label: 'Monthly Investment',
            value: _monthlyInvestment,
            min: 500,
            max: 100000,
            divisions: 199,
            prefix: '₹',
            controller: _monthlyInvestmentController,
            onChanged: (val) {
              setState(() {
                _monthlyInvestment = val;
                _monthlyInvestmentController.text = val.toStringAsFixed(0);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Expected Return (% p.a.)',
            value: _expectedReturn,
            min: 1,
            max: 30,
            divisions: 290,
            suffix: '%',
            controller: _expectedReturnController,
            onChanged: (val) {
              setState(() {
                _expectedReturn = val;
                _expectedReturnController.text = val.toStringAsFixed(1);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Time Period',
            value: _timePeriod.toDouble(),
            min: 1,
            max: 40,
            divisions: 39,
            suffix: ' Years',
            controller: _timePeriodController,
            onChanged: (val) {
              setState(() {
                _timePeriod = val.toInt();
                _timePeriodController.text = val.toInt().toString();
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Annual Step-Up',
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
          if (_stepUpPercentage > 0) ...[
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
                      'Your SIP amount will increase by ${_stepUpPercentage.toStringAsFixed(1)}% every year',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$prefix${value.toStringAsFixed(suffix == '%' ? 1 : 0)}$suffix',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit, size: 16, color: Colors.orange.shade700),
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
              borderSide: BorderSide(color: Colors.orange.shade600, width: 2),
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
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Invested',
            _totalInvestment,
            Icons.account_balance_wallet_rounded,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Returns',
            _estimatedReturns,
            Icons.trending_up_rounded,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total',
            _totalValue,
            Icons.account_balance_rounded,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
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
    double investmentPercentage = (_totalInvestment / _totalValue) * 100;
    double returnsPercentage = (_estimatedReturns / _totalValue) * 100;

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
            'Wealth Growth',
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
                  returnsPercentage: returnsPercentage,
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
                'Returns',
                Colors.green.shade600,
                returnsPercentage,
                _estimatedReturns,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: investmentPercentage.toInt(),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${investmentPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: returnsPercentage.toInt(),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${returnsPercentage.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
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
            'Year-wise Investment Growth',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _stepUpPercentage > 0
                ? 'With ${_stepUpPercentage.toStringAsFixed(1)}% annual step-up'
                : 'Regular SIP without step-up',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.orange.shade50),
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
                    'Monthly SIP',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Invested',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Returns',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Value',
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
                        '₹${(row['sip']).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['totalInvestment']).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['totalValue'] - row['totalInvestment']).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['totalValue']).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 11,
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
    _monthlyInvestmentController.dispose();
    _expectedReturnController.dispose();
    _timePeriodController.dispose();
    _stepUpController.dispose();
    super.dispose();
  }
}

class PieChartPainter extends CustomPainter {
  final double investmentPercentage;
  final double returnsPercentage;

  PieChartPainter({
    required this.investmentPercentage,
    required this.returnsPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    final investmentPaint = Paint()
      ..color = Colors.blue.shade600
      ..style = PaintingStyle.fill;

    final returnsPaint = Paint()
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
      (returnsPercentage / 100) * 2 * pi,
      true,
      returnsPaint,
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
