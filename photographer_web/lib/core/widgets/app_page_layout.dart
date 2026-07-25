import 'package:flutter/material.dart';

class AppPageLayout extends StatelessWidget {
  final Widget child;

  const AppPageLayout({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: child,
    );
  }
}