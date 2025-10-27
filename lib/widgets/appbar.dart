import 'package:flutter/material.dart';

AppBar appBar() {
  return AppBar(
    backgroundColor: Colors.blue.shade700,
    elevation: 0,
    leading: Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    ),
  );
}
