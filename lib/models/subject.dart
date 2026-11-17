import 'package:flutter/material.dart';

class Subject {
  final String code;
  final String name;
  final String section;
  final String time;
  final String room;
  final String teacher;
  final String status;
  final String dayOfWeek; // 'MON' | 'TUE' | 'WED' | 'THU' | 'FRI'
  final String courseSummary;
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
    this.dayOfWeek = 'MON',
    this.courseSummary = '',
    this.progress = 0,
    this.pendingAssignments = 0,
    this.isLab = false,
    this.leftBorderColor,
  });

  String get displayName =>
      section.isNotEmpty ? '$code — $name ($section)' : '$code — $name';
  String get shortName => code;
}
