import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color kDark = Color(0xFF420671);
const Color kMain = Color(0xFF4D287B);
const Color kMid = Color(0xFF652D91);
const Color kLight = Color(0xFF7632AB);
const Color kGold = Color(0xFFF6DC04);
const Color kCream = Color(0xFFF7E7BB);
const Color kBg = Color(0xFFF5F3FA);
const Color kBorderLight = Color(0xFFCBB9E6);

class AppColors {
  static const dark = kDark;
  static const main = kMain;
  static const mid = kMid;
  static const light = kLight;
  static const gold = kGold;
  static const cream = kCream;
  static const bg = kBg;
  static const borderLight = kBorderLight;
}

class AppText {
  static TextStyle kanit({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
  }) {
    return GoogleFonts.kanit(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? kDark,
        foregroundColor: foregroundColor ?? Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        textStyle: AppText.kanit(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      child: Text(text),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color borderColor;
  final Color textColor;

  const GhostButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.borderColor = kMid,
    this.textColor = kMid,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor),
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        textStyle: AppText.kanit(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      child: Text(text),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final Border? border;
  final EdgeInsetsGeometry padding;
  final double radius;

  const AppCard({
    super.key,
    required this.child,
    this.color,
    this.border,
    this.padding = const EdgeInsets.all(16),
    this.radius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: [
          BoxShadow(
            color: kDark.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ChipTag extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const ChipTag({
    super.key,
    required this.label,
    this.backgroundColor = Colors.white,
    this.textColor = kMid,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: backgroundColor == Colors.white ? Border.all(color: kBorderLight) : null,
      ),
      child: Text(
        label,
        style: AppText.kanit(fontSize: 11, fontWeight: FontWeight.w600, color: textColor),
      ),
    );
  }
}

class BottomNavItem {
  final String route;
  final String label;
  final IconData icon;

  BottomNavItem({required this.route, required this.label, required this.icon});
}

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
