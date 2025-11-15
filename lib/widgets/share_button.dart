import 'package:flutter/material.dart';

class ShareResultButton extends StatelessWidget {
  final VoidCallback onShare;
  final String label;
  final Color? color;

  const ShareResultButton({
    super.key,
    required this.onShare,
    this.label = 'Share Result',
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onShare,
      icon: const Icon(Icons.share),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class ResultActionBar extends StatelessWidget {
  final VoidCallback onShare;
  final String calculatorName;
  final String mainResult;
  final String mainLabel;

  const ResultActionBar({
    super.key,
    required this.onShare,
    required this.calculatorName,
    required this.mainResult,
    required this.mainLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mainLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  mainResult,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ShareResultButton(
            onShare: onShare,
            label: 'Share',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
}
