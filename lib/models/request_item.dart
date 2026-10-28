import 'package:flutter/material.dart';

class RequestItem {
  final String id;
  final String title;
  final String status; // 'รอดำเนินการ' | 'ช่างรับเรื่อง' | 'เสร็จแล้ว' | 'รออนุมัติ' | 'ส่งต่อช่างแล้ว'
  final Color chipColor;
  final double progress; // 0-1

  RequestItem({
    required this.id,
    required this.title,
    required this.status,
    required this.chipColor,
    this.progress = 0,
  });
}
