import 'package:flutter_test/flutter_test.dart';
import 'package:rmutp_campus_app/services/mock_data.dart';

void main() {
  group('MockData timetable', () {
    test('timetableStudent มี 3 วิชา และรหัสวิชาถูกต้อง', () {
      expect(MockData.timetableStudent.length, 3);
      expect(MockData.timetableStudent[0].code, 'ENGCE302');
      expect(MockData.timetableStudent[1].code, 'ENGCE305');
      expect(MockData.timetableStudent[2].code, 'GEN101');
    });

    test('timetableTeacher มี 2 วิชา', () {
      expect(MockData.timetableTeacher.length, 2);
      expect(MockData.timetableTeacher[0].code, 'ENGCE302');
      expect(MockData.timetableTeacher[1].code, 'ENGCE305');
    });
  });

  group('MockData courses', () {
    test('coursesStudent มี 3 วิชา', () {
      expect(MockData.coursesStudent.length, 3);
    });

    test('coursesTeacher มี 2 วิชา', () {
      expect(MockData.coursesTeacher.length, 2);
    });
  });

  group('MockData grades', () {
    test('gradesStudent มี 4 รายการ และมีคำเตือน 1 รายการ', () {
      expect(MockData.gradesStudent.length, 4);
      final warnings =
          MockData.gradesStudent.where((g) => g.isWarning).toList();
      expect(warnings.length, 1);
      expect(warnings.first.subjectCode, 'MATH201');
    });

    test('คะแนนเกรดตรงกับตัวอย่างใน mock data', () {
      expect(MockData.gradesStudent[0].score, 4.0);
      expect(MockData.gradesStudent[1].score, 3.5);
      expect(MockData.gradesStudent[2].score, 3.0);
      expect(MockData.gradesStudent[3].score, 2.5);
    });
  });

  group('MockData grade submit (teacher)', () {
    test('gradeSubmitRows มี 3 คน และสถานะถูกต้อง', () {
      expect(MockData.gradeSubmitRows.length, 3);
      expect(MockData.gradeSubmitRows[0].id, '650602001');
      expect(MockData.gradeSubmitRows[0].status, 'ส่งแล้ว');
      expect(MockData.gradeSubmitRows[1].id, '650602002');
      expect(MockData.gradeSubmitRows[1].status, 'ร่าง');
      expect(MockData.gradeSubmitRows[2].id, '650602003');
      expect(MockData.gradeSubmitRows[2].status, 'ร่าง');
    });
  });

  group('MockData news', () {
    test('newsList มี 3 รายการ และประเภทถูกต้อง', () {
      expect(MockData.newsList.length, 3);
      expect(MockData.newsList[0].type, 'ทุน');
      expect(MockData.newsList[1].type, 'ฝึกงาน');
      expect(MockData.newsList[2].type, 'กิจกรรม');
    });
  });

  group('MockData notifications', () {
    test('notifications มี 3 รายการ และหัวข้อถูกต้อง', () {
      expect(MockData.notifications.length, 3);
      expect(MockData.notifications[0].title, 'HW6 ใกล้ครบกำหนด');
      expect(MockData.notifications[1].title, 'ทุนคณะวิศวฯ ปิดรับ 30 ก.ย.');
      expect(MockData.notifications[2].title,
          'เลื่อนห้อง ENGCE305 → Lab 1502');
    });
  });

  group('MockData academic calendar', () {
    test('academicCalendar มี 4 รายการ', () {
      expect(MockData.academicCalendar.length, 4);
      expect(MockData.academicCalendar[0], '23 ก.ย. — หมดเขตส่ง HW6');
      expect(MockData.academicCalendar[3], '13–17 ต.ค. — สอบกลางภาค');
    });
  });

  group('MockData requests', () {
    test('requestsStudent มี 3 รายการ และรหัสคำร้องถูกต้อง', () {
      expect(MockData.requestsStudent.length, 3);
      expect(MockData.requestsStudent[0].id, '#RQ-1042');
      expect(MockData.requestsStudent[1].id, '#RQ-1039');
      expect(MockData.requestsStudent[2].id, '#RQ-1031');
    });

    test('requestsTeacher มี 2 รายการ', () {
      expect(MockData.requestsTeacher.length, 2);
    });

    test('ความคืบหน้าของคำร้องทุกรายการอยู่ระหว่าง 0 ถึง 1', () {
      final all = [...MockData.requestsStudent, ...MockData.requestsTeacher];
      for (final r in all) {
        expect(r.progress, greaterThanOrEqualTo(0.0));
        expect(r.progress, lessThanOrEqualTo(1.0));
      }
    });
  });
}
