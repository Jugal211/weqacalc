import 'package:flutter/material.dart';

Widget notificationBell() {
  return Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(
      Icons.notifications_outlined,
      color: Colors.white,
      size: 24,
    ),
  );
}
