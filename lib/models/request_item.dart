import 'package:flutter/material.dart';

class RequestItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String studentId;
  String status; // สถานะฝั่งนักศึกษา เช่น 'รอดำเนินการ' | 'ช่างรับเรื่อง' | 'เสร็จแล้ว • โหลด PDF'
  String statusTeacher; // สถานะฝั่งอาจารย์ เช่น 'รออนุมัติ' | 'ส่งต่อช่างแล้ว' | 'เสร็จสิ้น' | 'ตีกลับ'
  Color chipColor;
  double progress; // 0-1
  final String? resultPdfUrl;

  RequestItem({
    required this.id,
    required this.title,
    this.description = '',
    this.category = 'document',
    this.studentId = '650602001',
    required this.status,
    this.statusTeacher = 'รออนุมัติ',
    required this.chipColor,
    this.progress = 0,
    this.resultPdfUrl,
  });
}
