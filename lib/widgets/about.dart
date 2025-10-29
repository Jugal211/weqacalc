import 'package:flutter/material.dart';

void showAboutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.calculate_rounded, color: Colors.blue, size: 28),
          SizedBox(width: 12),
          Text('About'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Calculator',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Version 1.0.0', style: TextStyle(color: Colors.grey.shade600)),
          SizedBox(height: 16),
          Text(
            'A comprehensive financial calculator app to help you make smart money decisions.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          SizedBox(height: 16),
          Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('• 14+ Financial Calculators'),
          Text('• Loan & EMI Planning'),
          Text('• Investment Analysis'),
          Text('• Retirement Planning'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Close'),
        ),
      ],
    ),
  );
}
