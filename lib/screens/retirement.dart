import 'package:flutter/material.dart';
import '../utils/retirementcalcgrid.dart';
import '../widgets/buildheader.dart';

class RetirementScreen extends StatelessWidget {
  const RetirementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      'Retirement Calculators',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildCalculatorGrid(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
