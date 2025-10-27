import 'package:flutter/material.dart';
import 'dart:math';

class CAGRCalculator extends StatefulWidget {
  const CAGRCalculator({super.key});

  @override
  State<CAGRCalculator> createState() => _CAGRCalculatorState();
}

class _CAGRCalculatorState extends State<CAGRCalculator> {
  final _initialInvestmentController = TextEditingController();
  final _currentValueController = TextEditingController();
  final _durationController = TextEditingController();

  double _initialInvestment = 100000;
  double _currentValue = 200000;
  double _duration = 5;

  double _cagr = 0;
  double _absoluteReturn = 0;
  double _absoluteReturnPercentage = 0;
  double _totalGain = 0;

  @override
  void initState() {
    super.initState();
    _initialInvestmentController.text = _initialInvestment.toStringAsFixed(0);
    _currentValueController.text = _currentValue.toStringAsFixed(0);
    _durationController.text = _duration.toStringAsFixed(1);
    _calculate();
  }

  void _calculate() {
    // CAGR Formula: [(Ending Value / Beginning Value)^(1 / Number of Years)] - 1
    if (_initialInvestment > 0 && _duration > 0) {
      _cagr =
          (pow(_currentValue / _initialInvestment, 1 / _duration) - 1) * 100;
      _absoluteReturn = _currentValue - _initialInvestment;
      _absoluteReturnPercentage = (_absoluteReturn / _initialInvestment) * 100;
      _totalGain = _absoluteReturn;
    } else {
      _cagr = 0;
      _absoluteReturn = 0;
      _absoluteReturnPercentage = 0;
      _totalGain = 0;
    }
    setState(() {});
  }

  List<Map<String, dynamic>> _getYearlyProjection() {
    List<Map<String, dynamic>> projection = [];
    double currentAmount = _initialInvestment;
    double yearlyGrowthRate = _cagr / 100;

    projection.add({
      'year': 0,
      'value': _initialInvestment,
      'gain': 0.0,
      'totalGain': 0.0,
    });

    for (int year = 1; year <= _duration.ceil(); year++) {
      double previousValue = currentAmount;
      currentAmount = currentAmount * (1 + yearlyGrowthRate);
      double yearlyGain = currentAmount - previousValue;
      double totalGainSoFar = currentAmount - _initialInvestment;

      projection.add({
        'year': year,
        'value': currentAmount,
        'gain': yearlyGain,
        'totalGain': totalGainSoFar,
      });
    }

    return projection;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CAGR Calculator'),
        backgroundColor: Colors.indigo.shade600,
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
                  _buildComparisonCard(),
                  const SizedBox(height: 20),
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  _buildYearlyProjection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    Color cagrColor = _cagr >= 0 ? Colors.green : Colors.red;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.indigo.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Icon(Icons.trending_up_rounded, size: 70, color: Colors.white),
          const SizedBox(height: 20),
          const Text(
            'CAGR',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              '${_cagr.toStringAsFixed(2)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'per annum over ${_duration.toStringAsFixed(1)} years',
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
            label: 'Initial Investment',
            value: _initialInvestment,
            min: 1000,
            max: 10000000,
            divisions: 1000,
            prefix: '₹',
            controller: _initialInvestmentController,
            onChanged: (val) {
              setState(() {
                _initialInvestment = val;
                _initialInvestmentController.text = val.toStringAsFixed(0);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Current Value',
            value: _currentValue,
            min: 1000,
            max: 50000000,
            divisions: 1000,
            prefix: '₹',
            controller: _currentValueController,
            onChanged: (val) {
              setState(() {
                _currentValue = val;
                _currentValueController.text = val.toStringAsFixed(0);
                _calculate();
              });
            },
          ),
          const SizedBox(height: 24),
          _buildSliderInput(
            label: 'Investment Duration',
            value: _duration,
            min: 0.5,
            max: 50,
            divisions: 99,
            suffix: ' Years',
            controller: _durationController,
            onChanged: (val) {
              setState(() {
                _duration = val;
                _durationController.text = val.toStringAsFixed(1);
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
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade200, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$prefix${value.toStringAsFixed(suffix.contains('Year') ? 1 : 0)}$suffix',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit, size: 16, color: Colors.indigo.shade700),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.indigo.shade600,
            inactiveTrackColor: Colors.indigo.shade100,
            thumbColor: Colors.indigo.shade700,
            overlayColor: Colors.indigo.shade100,
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
                suffix.contains('Year') ? 1 : 0,
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
              borderSide: BorderSide(color: Colors.indigo.shade600, width: 2),
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
              backgroundColor: Colors.indigo.shade600,
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
            'Initial',
            _initialInvestment,
            Icons.account_balance_wallet_rounded,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildResultCard(
            'Current',
            _currentValue,
            Icons.account_balance_rounded,
            Colors.indigo,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildResultCard(
            'Gain',
            _totalGain,
            Icons.trending_up_rounded,
            _totalGain >= 0 ? Colors.green : Colors.red,
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

  Widget _buildComparisonCard() {
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
            'Returns Analysis',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          _buildComparisonRow(
            'CAGR (Annualized Return)',
            '${_cagr.toStringAsFixed(2)}%',
            Icons.show_chart_rounded,
            Colors.indigo.shade600,
          ),
          const SizedBox(height: 16),
          _buildComparisonRow(
            'Absolute Return',
            '${_absoluteReturnPercentage.toStringAsFixed(2)}%',
            Icons.percent_rounded,
            Colors.purple.shade600,
          ),
          const SizedBox(height: 16),
          _buildComparisonRow(
            'Total Gain',
            '₹${_totalGain.toStringAsFixed(0)}',
            Icons.account_balance_wallet_rounded,
            _totalGain >= 0 ? Colors.green.shade600 : Colors.red.shade600,
          ),
          const SizedBox(height: 16),
          _buildComparisonRow(
            'Investment Duration',
            '${_duration.toStringAsFixed(1)} years',
            Icons.timer_rounded,
            Colors.orange.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
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
                  fontWeight: FontWeight.w500,
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade50, Colors.indigo.shade100],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_rounded, color: Colors.indigo.shade700, size: 24),
              const SizedBox(width: 12),
              Text(
                'What is CAGR?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'CAGR (Compound Annual Growth Rate) is the rate at which your investment would have grown if it grew at a steady rate annually. It smooths out the volatility and gives you a single growth rate over the entire period.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.indigo.shade800,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calculate_rounded,
                  color: Colors.indigo.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Formula: [(Final Value / Initial Value)^(1/Years)] - 1',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.indigo.shade700,
                      fontFamily: 'monospace',
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

  Widget _buildYearlyProjection() {
    final projection = _getYearlyProjection();

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
            'Year-wise Growth Projection',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Based on ${_cagr.toStringAsFixed(2)}% CAGR',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
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
                    'Value',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Yearly Gain',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Total Gain',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
              rows: projection.map((row) {
                bool isCurrentYear = row['year'] == _duration.floor();
                return DataRow(
                  color: isCurrentYear
                      ? WidgetStateProperty.all(Colors.indigo.shade50)
                      : null,
                  cells: [
                    DataCell(
                      Text(
                        '${row['year']}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isCurrentYear
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['value']).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isCurrentYear
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['gain']).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                    DataCell(
                      Text(
                        '₹${(row['totalGain']).toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.indigo.shade700,
                          fontWeight: FontWeight.w600,
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
    _initialInvestmentController.dispose();
    _currentValueController.dispose();
    _durationController.dispose();
    super.dispose();
  }
}
