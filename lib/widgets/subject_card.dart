import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';

class SubjectCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? leftBorderColor;
  final List<Widget> actions;
  final VoidCallback? onTap;

  const SubjectCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.leftBorderColor,
    this.actions = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: Colors.white,
      border: leftBorderColor != null
          ? Border(left: BorderSide(color: leftBorderColor!, width: 6))
          : null,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppText.kanit(fontSize: 15, fontWeight: FontWeight.w600, color: kDark),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: AppText.kanit(fontSize: 12, color: Colors.grey.shade600),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(children: actions),
          ],
        ],
      ),
    );
  }
}
