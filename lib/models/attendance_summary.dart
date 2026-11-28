/// สรุปการเช็กชื่อของนักศึกษารายวิชา (คำนวณจาก attendance_records + sessions)
class AttendanceCourseSummary {
  final String subjectCode;
  final String subjectName;
  final int present;
  final int late;
  final int absent;

  const AttendanceCourseSummary({
    required this.subjectCode,
    required this.subjectName,
    required this.present,
    required this.late,
    required this.absent,
  });

  int get total => present + late + absent;
  int get attended => present + late;
  int get percent => total == 0 ? 0 : ((attended / total) * 100).round();
}
