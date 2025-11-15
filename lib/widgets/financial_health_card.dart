import 'package:flutter/material.dart';
import 'package:weqacalc/services/financial_health_service.dart';

class FinancialHealthScoreCard extends StatelessWidget {
  final FinancialHealthScore score;

  const FinancialHealthScoreCard({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: score.getScoreColor().withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: score.getScoreColor().withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(score.getScoreEmoji(), style: const TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Financial Health Score',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${score.score}/100 - ${score.category}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: score.getScoreColor(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: score.score / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(score.getScoreColor()),
            ),
          ),
          const SizedBox(height: 20),
          // Recommendation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: score.getScoreColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              score.recommendation,
              style: TextStyle(
                fontSize: 13,
                color: score.getScoreColor(),
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
          ),
          if (score.strengths.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Strengths',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...score.strengths.map((strength) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text('✓ ', style: TextStyle(color: Colors.green.shade700)),
                    Expanded(
                      child: Text(
                        strength,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (score.improvements.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Areas to Improve',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...score.improvements.map((improvement) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Text('→ ', style: TextStyle(color: Colors.orange.shade700)),
                    Expanded(
                      child: Text(
                        improvement,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
