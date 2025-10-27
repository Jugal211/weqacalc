import 'package:flutter/material.dart';
import 'dart:math';

// void main() {
//   runApp(const MyApp());
//   @override
//   void dispose() {
//     _loanAmountController.dispose();
//     _interestRateController.dispose();
//     _loanTenureController.dispose();
//     super.dispose();
//   }
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Home Loan Calculator',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
//       home: const HomeLoanCalculator(),
//     );
//   }
// }

class HomeLoanCalculator extends StatefulWidget {
  const HomeLoanCalculator({super.key});

  @override
  State<HomeLoanCalculator> createState() => _HomeLoanCalculatorState();
}

class _HomeLoanCalculatorState extends State<HomeLoanCalculator> {
  final _loanAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _loanTenureController = TextEditingController();

  double _loanAmount = 5000000;
  double _interestRate = 8.5;
  int _loanTenure = 20;

  double _monthlyEMI = 0;
  double _totalAmount = 0;
  double _totalInterest = 0;

  @override
  void initState() {
    super.initState();
    _loanAmountController.text = _loanAmount.toStringAsFixed(0);
    _interestRateController.text = _interestRate.toStringAsFixed(1);
    _loanTenureController.text = _loanTenure.toString();
    _calculateEMI();
  }

  void _calculateEMI() {
    double principal = _loanAmount;
    double monthlyRate = _interestRate / 12 / 100;
    int months = _loanTenure * 12;

    if (monthlyRate == 0) {
      _monthlyEMI = principal / months;
    } else {
      _monthlyEMI =
          principal *
          monthlyRate *
          pow(1 + monthlyRate, months) /
          (pow(1 + monthlyRate, months) - 1);
    }

    _totalAmount = _monthlyEMI * months;
    _totalInterest = _totalAmount - principal;

    setState(() {});
  }

  List<Map<String, dynamic>> _generateAmortizationSchedule() {
    List<Map<String, dynamic>> schedule = [];
    double balance = _loanAmount;
    double monthlyRate = _interestRate / 12 / 100;

    for (int i = 1; i <= _loanTenure * 12; i++) {
      double interest = balance * monthlyRate;
      double principal = _monthlyEMI - interest;
      balance -= principal;

      if (balance < 0) balance = 0;

      schedule.add({
        'month': i,
        'emi': _monthlyEMI,
        'principal': principal,
        'interest': interest,
        'balance': balance,
      });
    }

    return schedule;
  }

  List<Map<String, dynamic>> _getYearlySchedule() {
    final schedule = _generateAmortizationSchedule();
    final yearlySchedule = <Map<String, dynamic>>[];

    for (int year = 1; year <= _loanTenure; year++) {
      double yearlyPrincipal = 0;
      double yearlyInterest = 0;
      int startMonth = (year - 1) * 12;
      int endMonth = year * 12;

      for (int i = startMonth; i < endMonth && i < schedule.length; i++) {
        yearlyPrincipal += schedule[i]['principal'];
        yearlyInterest += schedule[i]['interest'];
      }

      double balance = endMonth - 1 < schedule.length
          ? schedule[endMonth - 1]['balance']
          : 0;

      yearlySchedule.add({
        'year': year,
        'principal': yearlyPrincipal,
        'interest': yearlyInterest,
        'balance': balance,
      });
    }

    return yearlySchedule;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Loan Calculator'),
        backgroundColor: Colors.blue.shade700,
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
                  _buildPieChart(),
                  const SizedBox(height: 20),
                  _buildPaymentBreakdownChart(),
                  const SizedBox(height: 20),
                  _buildPrincipalVsInterestChart(),
                  const SizedBox(height: 20),
                  _buildAmortizationTable(),
                  const SizedBox(height: 20),
                  _buildDetailedMonthlySchedule(),
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
          colors: [Colors.blue.shade700, Colors.blue.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.home_rounded, size: 70, color: Colors.white),
          const SizedBox(height: 20),
          const Text(
            'Monthly EMI',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${_monthlyEMI.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'per month for $_loanTenure years',
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
            color: Colors.black.withOpacity(0.08),
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
                _calculateEMI();
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
                _calculateEMI();
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
                _calculateEMI();
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
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600,
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
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$prefix${value.toStringAsFixed(suffix == '%' ? 1 : 0)}$suffix',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit, size: 16, color: Colors.blue.shade700),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.blue.shade600,
            inactiveTrackColor: Colors.blue.shade100,
            thumbColor: Colors.blue.shade700,
            overlayColor: Colors.blue.shade100,
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
              borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
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
              backgroundColor: Colors.blue.shade600,
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
            'Principal',
            _loanAmount,
            Icons.account_balance_wallet,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Interest',
            _totalInterest,
            Icons.trending_up,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Total',
            _totalAmount,
            Icons.payments,
            Colors.green,
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
            color: Colors.black.withOpacity(0.06),
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

  Widget _buildPieChart() {
    double principalPercentage = (_loanAmount / _totalAmount) * 100;
    double interestPercentage = (_totalInterest / _totalAmount) * 100;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Distribution',
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
              ),
              const SizedBox(width: 24),
              _buildLegendItem(
                'Interest',
                Colors.orange.shade500,
                interestPercentage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, double percentage) {
    return Row(
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
        Column(
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
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentBreakdownChart() {
    double principalPercentage = (_loanAmount / _totalAmount) * 100;
    double interestPercentage = (_totalInterest / _totalAmount) * 100;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Breakdown',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: principalPercentage.toInt(),
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
                      '${principalPercentage.toStringAsFixed(1)}%',
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
                flex: interestPercentage.toInt(),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                    ),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${interestPercentage.toStringAsFixed(1)}%',
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
          const SizedBox(height: 20),
          _buildBreakdownRow(
            'Principal Amount',
            _loanAmount,
            Colors.blue.shade600,
          ),
          const SizedBox(height: 12),
          _buildBreakdownRow(
            'Total Interest',
            _totalInterest,
            Colors.orange.shade500,
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          _buildBreakdownRow(
            'Total Payable',
            _totalAmount,
            Colors.green.shade600,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    double amount,
    Color color, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 17 : 15,
            color: Colors.grey.shade700,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: isTotal ? 19 : 16,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPrincipalVsInterestChart() {
    final yearlySchedule = _getYearlySchedule();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Principal vs Interest Over Time',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 250,
            child: CustomPaint(
              painter: BarChartPainter(yearlySchedule: yearlySchedule),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmortizationTable() {
    final yearlySchedule = _getYearlySchedule();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yearly Amortization Schedule',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Payment breakdown by year',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
              border: TableBorder.all(color: Colors.grey.shade300, width: 1),
              columns: const [
                DataColumn(
                  label: Text(
                    'Year',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Principal',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Interest',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Balance',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
              rows: yearlySchedule.map((row) {
                return DataRow(
                  cells: [
                    DataCell(Text('${row['year']}')),
                    DataCell(Text('₹${(row['principal']).toStringAsFixed(0)}')),
                    DataCell(Text('₹${(row['interest']).toStringAsFixed(0)}')),
                    DataCell(Text('₹${(row['balance']).toStringAsFixed(0)}')),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedMonthlySchedule() {
    final monthlySchedule = _generateAmortizationSchedule();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Text(
                  'Monthly Payment Schedule',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${monthlySchedule.length} months',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Complete month-by-month breakdown',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          Container(
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              itemCount: monthlySchedule.length,
              itemBuilder: (context, index) {
                final row = monthlySchedule[index];
                final isEvenRow = index % 2 == 0;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isEvenRow ? Colors.grey.shade50 : Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          'Month ${row['month']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'P: ₹${(row['principal']).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              'I: ₹${(row['interest']).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Bal: ₹${(row['balance']).toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
      ..color = Colors.orange.shade500
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

class BarChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> yearlySchedule;

  BarChartPainter({required this.yearlySchedule});

  @override
  void paint(Canvas canvas, Size size) {
    if (yearlySchedule.isEmpty) return;

    final barWidth = size.width / (yearlySchedule.length * 2.5);
    final maxValue = yearlySchedule
        .map((e) => max(e['principal'], e['interest']))
        .reduce(max);

    for (int i = 0; i < yearlySchedule.length; i++) {
      final x = (i * 2.5 * barWidth) + barWidth / 2;
      final principalHeight =
          (yearlySchedule[i]['principal'] / maxValue) * (size.height - 40);
      final interestHeight =
          (yearlySchedule[i]['interest'] / maxValue) * (size.height - 40);

      // Principal bar
      final principalPaint = Paint()
        ..color = Colors.blue.shade600
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(
          x,
          size.height - principalHeight - 20,
          barWidth * 0.8,
          principalHeight,
        ),
        principalPaint,
      );

      // Interest bar
      final interestPaint = Paint()
        ..color = Colors.orange.shade500
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(
          x + barWidth,
          size.height - interestHeight - 20,
          barWidth * 0.8,
          interestHeight,
        ),
        interestPaint,
      );

      // Year label
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'Y${yearlySchedule[i]['year']}',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x + barWidth / 2, size.height - 15));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
