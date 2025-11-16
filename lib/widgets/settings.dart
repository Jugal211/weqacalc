import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weqacalc/widgets/about.dart' as about;
import 'package:weqacalc/widgets/financial_profile_dialog.dart';
import 'package:weqacalc/services/user_data_service.dart';
import 'package:weqacalc/services/referral_service.dart';
import 'package:share_plus/share_plus.dart';

Widget buildSettingOption(
  BuildContext context,
  String title,
  IconData icon,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 22),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey.shade400,
            size: 16,
          ),
        ],
      ),
    ),
  );
}

class SettingsBottomSheet extends StatelessWidget {
  final UserDataService? userDataService;
  final ReferralService? referralService;

  const SettingsBottomSheet({
    super.key,
    this.userDataService,
    this.referralService,
  });

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
      throw 'Could not launch $url';
    }
  }

  void _showUsageStats(BuildContext context, UserDataService userDataService) {
    final usage = userDataService.getCalculatorUsage();
    final totalUsed = userDataService.getTotalCalculatorsUsed();
    final totalCalculations = userDataService.getTotalCalculations();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calculator Usage Stats'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Unique Calculators Used', totalUsed.toString()),
              const SizedBox(height: 8),
              _buildStatRow('Total Calculations', totalCalculations.toString()),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Calculator Breakdown:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              if (usage.isEmpty)
                const Text(
                  'No calculators used yet',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ...usage.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key.toUpperCase(),
                          style: const TextStyle(fontSize: 13),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${entry.value}x',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Icon(Icons.settings_rounded, color: Colors.blue, size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            if (userDataService != null)
              buildSettingOption(
                context,
                'Financial Profile',
                Icons.account_balance_wallet_rounded,
                () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => FinancialProfileDialog(
                      userDataService: userDataService!,
                    ),
                  );
                },
              ),
            if (userDataService != null)
              buildSettingOption(
                context,
                'Calculator Usage Stats',
                Icons.bar_chart_rounded,
                () {
                  Navigator.pop(context);
                  _showUsageStats(context, userDataService!);
                },
              ),
            if (referralService != null)
              buildSettingOption(
                context,
                'Test Referral System',
                Icons.add_circle_outline_rounded,
                () async {
                  await referralService!.addReferral();
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Referral added! Total: ${referralService!.getReferralCount()}',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
            buildSettingOption(
              context,
              'About',
              Icons.info_outline_rounded,
              () {
                Navigator.pop(context);
                about.showAboutDialog(context);
              },
            ),
            buildSettingOption(
              context,
              'Rate Us',
              Icons.star_outline_rounded,
              () async {
                Navigator.pop(context);

                // Replace with your actual Play Store link
                const playStoreUrl =
                    'https://play.google.com/store/apps/details?id=com.wefin.calculator';

                try {
                  await _launchUrl(playStoreUrl);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Unable to open Play Store.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
            ),
            buildSettingOption(context, 'Share App', Icons.share_rounded, () async {
              Navigator.pop(context);

              const appLink =
                  'https://play.google.com/store/apps/details?id=com.wefin.calculator';

              await Share.share(
                '📱 Check out WeFin Calculator – your path to financial independence!\n$appLink',
                subject: 'WeFin Calculator',
              );
            }),
            buildSettingOption(
              context,
              'Privacy Policy',
              Icons.privacy_tip_outlined,
              () {
                Navigator.pop(context);
                _launchUrl(
                  'https://jugal211.github.io/weqacalc/privacy-policy.html',
                );
              },
            ),
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
