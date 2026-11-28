import 'package:flutter/material.dart';

class NotificationItem {
  final String title;
  final String subtitle;
  final Color accentColor;

  // คอลัมน์จากตาราง notifications
  bool isRead;
  final String? createdAt;

  NotificationItem({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    this.isRead = false,
    this.createdAt,
  });
}
