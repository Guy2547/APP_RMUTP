import 'package:flutter_test/flutter_test.dart';
import 'package:rmutp_campus_app/models/grade.dart';

void main() {
  group('StudentRow.total', () {
    test('รวมคะแนน midterm + finalExam + coursework ถูกต้อง', () {
      final row = StudentRow(
        id: '650602001',
        name: 'มินตรา',
        midterm: 26,
        finalExam: 33,
        coursework: 27,
      );
      expect(row.total, 86);
    });

    test('คะแนนเป็นศูนย์ทั้งหมดคืนค่า 0', () {
      final row = StudentRow(
        id: '650602001',
        name: 'ทดสอบ',
        midterm: 0,
        finalExam: 0,
        coursework: 0,
      );
      expect(row.total, 0);
    });

    test('คะแนนเต็มทุกอย่างคืนค่า 100', () {
      final row = StudentRow(
        id: '650602001',
        name: 'ทดสอบ',
        midterm: 30,
        finalExam: 40,
        coursework: 30,
      );
      expect(row.total, 100);
    });
  });

  group('StudentRow.gradeLetter', () {
    test('คืนค่า A เมื่อคะแนนรวม 80 ขึ้นไป', () {
      expect(
        StudentRow(id: '1', name: 'x', midterm: 30, finalExam: 40,
            coursework: 10).gradeLetter,
        'A',
      );
    });

    test('คืนค่า B+ เมื่อคะแนนรวม 75–79', () {
      expect(
        StudentRow(id: '1', name: 'x', midterm: 25, finalExam: 30,
            coursework: 20).gradeLetter,
        'B+',
      );
    });

    test('คืนค่า B เมื่อคะแนนรวม 70–74', () {
      expect(
        StudentRow(id: '1', name: 'x', midterm: 23, finalExam: 27,
            coursework: 20).gradeLetter,
        'B',
      );
    });

    test('คืนค่า C+ เมื่อคะแนนรวม 65–69', () {
      expect(
        StudentRow(id: '1', name: 'x', midterm: 20, finalExam: 25,
            coursework: 20).gradeLetter,
        'C+',
      );
    });

    test('คืนค่า C เมื่อคะแนนรวม 60–64', () {
      expect(
        StudentRow(id: '1', name: 'x', midterm: 20, finalExam: 24,
            coursework: 16).gradeLetter,
        'C',
      );
    });

    test('คืนค่า D+ เมื่อคะแนนรวม 55–59', () {
      expect(
        StudentRow(id: '1', name: 'x', midterm: 18, finalExam: 21,
            coursework: 16).gradeLetter,
        'D+',
      );
    });

    test('คืนค่า D เมื่อคะแนนรวม 50–54', () {
      expect(
        StudentRow(id: '1', name: 'x', midterm: 15, finalExam: 20,
            coursework: 15).gradeLetter,
        'D',
      );
    });

    test('คืนค่า F เมื่อคะแนนรวมต่ำกว่า 50', () {
      expect(
        StudentRow(id: '1', name: 'x', midterm: 10, finalExam: 20,
            coursework: 10).gradeLetter,
        'F',
      );
    });
  });

  group('StudentRow.isGreen / isAmber', () {
    test('isGreen เป็น true เมื่อคะแนนรวม >= 70', () {
      expect(
        StudentRow(id: '1', name: 'x', midterm: 30, finalExam: 30,
            coursework: 10).isGreen,
        isTrue,
      );
      expect(
        StudentRow(id: '1', name: 'x', midterm: 23, finalExam: 27,
            coursework: 20).isGreen,
        isTrue,
      );
    });

    test('isGreen เป็น false เมื่อคะแนนรวม < 70', () {
      expect(
        StudentRow(id: '1', name: 'x', midterm: 20, finalExam: 25,
            coursework: 20).isGreen,
        isFalse,
      );
    });

    test('isAmber เป็น true เมื่อคะแนนรวม 60–69', () {
      expect(
        StudentRow(id: '1', name: 'x', midterm: 20, finalExam: 25,
            coursework: 20).isAmber,
        isTrue,
      ); // 65
      expect(
        StudentRow(id: '1', name: 'x', midterm: 25, finalExam: 20,
            coursework: 20).isAmber,
        isTrue,
      ); // 65
    });

    test('isAmber เป็น false เมื่ออยู่นอกช่วง 60–69', () {
      expect(
        StudentRow(id: '1', name: 'x', midterm: 30, finalExam: 30,
            coursework: 10).isAmber,
        isFalse,
      );
      expect(
        StudentRow(id: '1', name: 'x', midterm: 10, finalExam: 20,
            coursework: 10).isAmber,
        isFalse,
      );
    });
  });
}
