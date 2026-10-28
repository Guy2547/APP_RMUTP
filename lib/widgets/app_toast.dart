import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';

class AppToast extends StatelessWidget {
  final String message;
  final bool visible;

  const AppToast({
    super.key,
    required this.message,
    required this.visible,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Positioned(
      left: 0,
      right: 0,
      bottom: 110,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1C0530),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Text(
            message,
            style: AppText.kanit(fontSize: 13, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
