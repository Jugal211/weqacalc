import 'package:flutter/material.dart';
import '../widgets/notification.dart';

Widget buildHeader() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade700, Colors.blue.shade500],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Financial Calculator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Smart money decisions made easy',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
            notificationBell(),
          ],
        ),
      ],
    ),
  );
}
