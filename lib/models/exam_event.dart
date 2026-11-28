/// กำหนดการสอบจากตาราง academic_calendar_events (event_type = 'exam')
class ExamEvent {
  final String title;
  final String dateDisplay;
  final String startDate;
  final String? endDate;
  final String description;

  const ExamEvent({
    required this.title,
    required this.dateDisplay,
    required this.startDate,
    this.endDate,
    this.description = '',
  });

  /// ฐานข้อมูลเก็บ event แบบกลางภาค/ปลายภาคไว้ในชื่อหัวข้อ
  bool get isFinal => title.contains('ปลาย');
}
