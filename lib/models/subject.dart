import 'package:flutter/material.dart';

class Subject {
  final String code;
  final String name;
  final String section;
  final String time;
  final String room;
  final String teacher;
  final String status;
  final int progress; // 0-100
  final int pendingAssignments;
  final bool isLab;
  final Color? leftBorderColor;

  Subject({
    required this.code,
    required this.name,
    required this.section,
    required this.time,
    required this.room,
    required this.teacher,
    required this.status,
    this.progress = 0,
    this.pendingAssignments = 0,
    this.isLab = false,
    this.leftBorderColor,
  });

  String get displayName => '$code — $name$section';
  String get shortName => code;
}
