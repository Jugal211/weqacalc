import 'package:flutter/material.dart';
import 'dart:math';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Retirement Calculator',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.teal, useMaterial3: true),
//       home: const RetirementCalculator(),
//     );
//   }
// }

class RetirementCalculator extends StatefulWidget {
  const RetirementCalculator({super.key});

  @override
  State<RetirementCalculator> createState() => _RetirementCalculatorState();
}

class _RetirementCalculatorState extends State<RetirementCalculator> {
  final _currentAgeController = TextEditingController();
  final _retirementAgeController = TextEditingController();
  final _lifeExpectancyController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _inflationRateController = TextEditingController();
  final _preReturnController = TextEditingController();
  final _postReturnController = TextEditingController();
  final _existingFundController = TextEditingController();

  double _currentAge = 27;
  double _retirementAge = 60;
  double _lifeExpectancy = 80;
  double _monthlyIncomeRequired = 100000;
  double _inflationRate = 6;
  double _preRetirementReturn = 12;
  double _postRetirementReturn = 8;
  double _existingFund = 100000;

  double _annualIncomeRequired = 0;
  double _totalCorpusRequired = 0;
  double _monthlySavingsRequired = 0;

  @override
  void initState() {
    super.initState();
    _currentAgeController.text = _currentAge.toStringAsFixed(0);
    _retirementAgeController.text = _retirementAge.toStringAsFixed(0);
    _lifeExpectancyController.text = _lifeExpectancy.toStringAsFixed(0);
    _monthlyIncomeController.text = _monthlyIncomeRequired.toStringAsFixed(0);
    _inflationRateController.text = _inflationRate.toStringAsFixed(1);
    _preReturnController.text = _preRetirementReturn.toStringAsFixed(1);
    _postReturnController.text = _postRetirementReturn.toStringAsFixed(1);
    _existingFundController.text = _existingFund.toStringAsFixed(0);
    _calculate();
  }

  void _calculate() {
    int yearsToRetirement = (_retirementAge - _currentAge).toInt();
    int yearsInRetirement = (_lifeExpectancy - _retirementAge).toInt();

    if (yearsToRetirement <= 0 || yearsInRetirement <= 0) {
      setState(() {
        _annualIncomeRequired = 0;
        _totalCorpusRequired = 0;
        _monthlySavingsRequired = 0;
      });
      return;
    }

    // Calculate future value of monthly income at retirement (adjusted for inflation)
    double futureMonthlyIncome =
        _monthlyIncomeRequired *
        pow(1 + _inflationRate / 100, yearsToRetirement);

    _annualIncomeRequired = futureMonthlyIncome * 12;

    // Calculate corpus required at retirement using present value of annuity formula
    // This corpus should generate the required income for retirement years
    double r = _postRetirementReturn / 100;
    double g = _inflationRate / 100;
    double n = yearsInRetirement.toDouble();

    // Using growing annuity formula: PV = PMT * [(1 - ((1+g)/(1+r))^n) / (r - g)]
    if ((r - g).abs() < 0.0001) {
      _totalCorpusRequired = _annualIncomeRequired * n / (1 + r);
    } else {
      _totalCorpusRequired =
          _annualIncomeRequired * (1 - pow((1 + g) / (1 + r), n)) / (r - g);
    }

    // Adjust for existing fund (grow it to retirement)
    double existingFundAtRetirement =
        _existingFund * pow(1 + _preRetirementReturn / 100, yearsToRetirement);

    // Corpus needed from new investments
    double corpusFromNewInvestments =
        _totalCorpusRequired - existingFundAtRetirement;

    if (corpusFromNewInvestments < 0) corpusFromNewInvestments = 0;

    // Calculate monthly SIP required using future value of annuity formula
    // FV = PMT * [((1+r)^n - 1) / r] * (1+r)
    double monthlyRate = _preRetirementReturn / 100 / 12;
    int totalMonths = yearsToRetirement * 12;

    if (monthlyRate == 0) {
      _monthlySavingsRequired = corpusFromNewInvestments / totalMonths;
    } else {
      _monthlySavingsRequired =
          corpusFromNewInvestments *
          monthlyRate /
          ((pow(1 + monthlyRate, totalMonths) - 1) * (1 + monthlyRate));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Retirement Planning Calculator'),
        backgroundColor: Colors.teal.shade700,
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
                  _buildDescriptionCard(),
                  const SizedBox(height: 20),
                  _buildInputCard(),
                  const SizedBox(height: 20),
                  _buildCalculateButton(),
                  const SizedBox(height: 20),
                  _buildResultCard(),
                  const SizedBox(height: 20),
                  _buildChartCard(),
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
          colors: [Colors.teal.shade700, Colors.teal.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.account_balance, size: 70, color: Colors.white),
          const SizedBox(height: 20),
          const Text(
            'Retirement Planning Calculator',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade200),
      ),
      child: Text(
        'Estimate your Retirement Corpus based on your expenses & the monthly investment required to achieve it.',
        style: TextStyle(
          fontSize: 14,
          color: Colors.teal.shade900,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
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
          _buildSliderInput(
            label: 'Current Age',
            value: _currentAge,
            min: 18,
            max: 80,
            divisions: 62,
            suffix: ' Years',
            controller: _currentAgeController,
            onChanged: (val) {
              setState(() {
                _currentAge = val;
                _currentAgeController.text = val.toStringAsFixed(0);
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Desired Retirement Age',
            value: _retirementAge,
            min: 40,
            max: 80,
            divisions: 40,
            suffix: ' Years',
            controller: _retirementAgeController,
            onChanged: (val) {
              setState(() {
                _retirementAge = val;
                _retirementAgeController.text = val.toStringAsFixed(0);
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Life Expectancy',
            value: _lifeExpectancy,
            min: 60,
            max: 100,
            divisions: 40,
            suffix: ' Years',
            controller: _lifeExpectancyController,
            onChanged: (val) {
              setState(() {
                _lifeExpectancy = val;
                _lifeExpectancyController.text = val.toStringAsFixed(0);
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Monthly Income Required in Retirement Years',
            value: _monthlyIncomeRequired,
            min: 10000,
            max: 500000,
            divisions: 490,
            prefix: '₹',
            controller: _monthlyIncomeController,
            onChanged: (val) {
              setState(() {
                _monthlyIncomeRequired = val;
                _monthlyIncomeController.text = val.toStringAsFixed(0);
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Expected Inflation Rate (%)',
            value: _inflationRate,
            min: 0,
            max: 15,
            divisions: 150,
            suffix: ' %',
            controller: _inflationRateController,
            onChanged: (val) {
              setState(() {
                _inflationRate = val;
                _inflationRateController.text = val.toStringAsFixed(1);
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Expected Return on Investment (Pre-retirement)',
            value: _preRetirementReturn,
            min: 0,
            max: 20,
            divisions: 200,
            suffix: ' %',
            controller: _preReturnController,
            onChanged: (val) {
              setState(() {
                _preRetirementReturn = val;
                _preReturnController.text = val.toStringAsFixed(1);
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Expected Return on Investment (Post-retirement)',
            value: _postRetirementReturn,
            min: 0,
            max: 15,
            divisions: 150,
            suffix: ' %',
            controller: _postReturnController,
            onChanged: (val) {
              setState(() {
                _postRetirementReturn = val;
                _postReturnController.text = val.toStringAsFixed(1);
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
                  fontSize: 14,
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
                  vertical: 8,
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
                      '$prefix${value >= 1000 ? value.toStringAsFixed(0) : value.toStringAsFixed(1)}$suffix',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit, size: 14, color: Colors.teal.shade700),
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
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: (val) {
              controller.text = val >= 1000
                  ? val.toStringAsFixed(0)
                  : val.toStringAsFixed(1);
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
              borderSide: BorderSide(color: Colors.teal.shade700, width: 2),
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
              backgroundColor: Colors.teal.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _calculate,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal.shade700,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Calculate',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildResultCard() {
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade700, Colors.teal.shade500],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Corpus Required For After Retirement',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '₹${(_totalCorpusRequired / 10000000).toStringAsFixed(2)} Crore',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildInfoBox(
                  'Annual Income Required Immediately After Retirement',
                  '₹${(_annualIncomeRequired / 100000).toStringAsFixed(2)} Lakh',
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoBox(
                  'Monthly Savings Required To Accumulate The Corpus',
                  '₹${_monthlySavingsRequired.toStringAsFixed(0)}',
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.teal.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard() {
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
            'Corpus Breakdown',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: CustomPaint(
                    painter: BarChartPainter(
                      annualIncome: _annualIncomeRequired,
                      totalCorpus: _totalCorpusRequired,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem(
                        'Annual Income Required Immediately After Retirement',
                        Colors.teal.shade600,
                      ),
                      const SizedBox(height: 16),
                      _buildLegendItem(
                        'Total Corpus Required For After Retirement',
                        Colors.orange.shade600,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade600,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${(_annualIncomeRequired / 100000).toStringAsFixed(2)} Lakh',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.orange.shade600,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '₹${(_totalCorpusRequired / 10000000).toStringAsFixed(2)} Crore',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
          ),
        ),
      ],
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

class BarChartPainter extends CustomPainter {
  final double annualIncome;
  final double totalCorpus;

  BarChartPainter({required this.annualIncome, required this.totalCorpus});

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue = max(annualIncome, totalCorpus);
    if (maxValue == 0) return;

    final barWidth = size.width / 3;
    final spacing = barWidth / 2;

    // Draw Annual Income bar
    final annualIncomeHeight = (annualIncome / maxValue) * (size.height - 40);
    final annualIncomePaint = Paint()
      ..color = Colors.teal.shade600
      ..style = PaintingStyle.fill;

    final annualIncomeRect = Rect.fromLTWH(
      spacing / 2,
      size.height - annualIncomeHeight - 20,
      barWidth,
      annualIncomeHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(annualIncomeRect, const Radius.circular(8)),
      annualIncomePaint,
    );

    // Draw Total Corpus bar
    final totalCorpusHeight = (totalCorpus / maxValue) * (size.height - 40);
    final totalCorpusPaint = Paint()
      ..color = Colors.orange.shade600
      ..style = PaintingStyle.fill;

    final totalCorpusRect = Rect.fromLTWH(
      spacing / 2 + barWidth + spacing,
      size.height - totalCorpusHeight - 20,
      barWidth,
      totalCorpusHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(totalCorpusRect, const Radius.circular(8)),
      totalCorpusPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
