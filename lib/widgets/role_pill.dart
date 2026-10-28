import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';

class RolePill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const RolePill({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? kGold : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? kGold : kBorderLight,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppText.kanit(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: active ? kDark : kMid,
          ),
        ),
      ),
    );
  }
}
