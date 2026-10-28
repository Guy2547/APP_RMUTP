class GradeItem {
  final String subjectCode;
  final String subjectName;
  final String letter;
  final double score;
  final bool isWarning;

  GradeItem({
    required this.subjectCode,
    required this.subjectName,
    required this.letter,
    required this.score,
    this.isWarning = false,
  });
}

class StudentRow {
  final String id;
  final String name;
  int midterm; // /30
  int finalExam; // /40
  int coursework; // /30
  String status; // 'ส่งแล้ว' | 'ร่าง'

  StudentRow({
    required this.id,
    required this.name,
    required this.midterm,
    required this.finalExam,
    required this.coursework,
    this.status = 'ร่าง',
  });

  int get total => midterm + finalExam + coursework;

  String get gradeLetter {
    if (total >= 80) return 'A';
    if (total >= 75) return 'B+';
    if (total >= 70) return 'B';
    if (total >= 65) return 'C+';
    if (total >= 60) return 'C';
    if (total >= 55) return 'D+';
    if (total >= 50) return 'D';
    return 'F';
  }

  bool get isGreen => total >= 70;
  bool get isAmber => total >= 60 && total < 70;
}
