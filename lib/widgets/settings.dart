import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weqacalc/widgets/about.dart' as about;

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
  const SettingsBottomSheet({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.inAppWebView)) {
      throw 'Could not launch $url';
    }
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
              () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Thank you for your support!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
            buildSettingOption(context, 'Share App', Icons.share_rounded, () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Share feature coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            }),
            buildSettingOption(
              context,
              'Privacy Policy',
              Icons.privacy_tip_outlined,
              () {
                Navigator.pop(context);
                _launchUrl(
                  'https://github.com/Jugal211/weqacalc/blob/main/PRIVACY_POLICY.md',
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
