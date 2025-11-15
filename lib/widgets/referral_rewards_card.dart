import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:weqacalc/services/referral_service.dart';

class ReferralRewardsCard extends StatelessWidget {
  final int referralCount;
  final List<ReferralReward> rewards;
  final VoidCallback? onShareReferralCode;

  const ReferralRewardsCard({
    super.key,
    required this.referralCount,
    required this.rewards,
    this.onShareReferralCode,
  });

  @override
  Widget build(BuildContext context) {
    final nextReward = rewards.firstWhereOrNull((r) => !r.isUnlocked);

    final progress = nextReward != null
        ? (referralCount / nextReward.requiredReferrals).clamp(0.0, 1.0)
        : 1.0;

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
          // Header with title and count
          Row(
            children: [
              const Text('🎁', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Referral Rewards',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$referralCount successful referrals',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${rewards.where((r) => r.isUnlocked).length}/${rewards.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Share referral code button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onShareReferralCode,
              icon: const Icon(Icons.share),
              label: const Text('Share Your Referral Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Progress to next reward
          if (nextReward != null) ...[
            Text(
              'Progress to: ${nextReward.title}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.purple.shade400,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$referralCount / ${nextReward.requiredReferrals} referrals',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
          ],

          // Rewards list
          const Text(
            'Available Rewards',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rewards.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final reward = rewards[index];
              return _buildRewardItem(reward);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(ReferralReward reward) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: reward.isUnlocked ? Colors.purple.shade50 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: reward.isUnlocked
              ? Colors.purple.shade300
              : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Checkbox or lock icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: reward.isUnlocked
                  ? Colors.purple.shade400
                  : Colors.grey.shade400,
            ),
            child: Center(
              child: Text(
                reward.isUnlocked ? '✓' : '🔒',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: reward.isUnlocked
                        ? Colors.purple.shade900
                        : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  reward.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: reward.isUnlocked
                        ? Colors.purple.shade700
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (reward.isUnlocked)
            Text(
              '✓ Unlocked',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade400,
              ),
            ),
        ],
      ),
    );
  }
}
