import 'package:flutter_test/flutter_test.dart';
import 'package:rmutp_campus_app/screens/login_screen.dart';

void main() {
  group('normalizeLoginIdentifier', () {
    test('รหัสนักศึกษา (ตัวเลข) ถูกแปลงเป็นอีเมลมหาวิทยาลัย', () {
      expect(
        normalizeLoginIdentifier('650602001'),
        's650602001@rmutp.ac.th',
      );
    });

    test('ตัดช่องว่างก่อน/หลัง', () {
      expect(
        normalizeLoginIdentifier('  650602001  '),
        's650602001@rmutp.ac.th',
      );
    });

    test('อีเมลที่กรอกมาครบอยู่แล้วต้องไม่ถูกเปลี่ยน', () {
      expect(
        normalizeLoginIdentifier('surachai.w@rmutp.ac.th'),
        'surachai.w@rmutp.ac.th',
      );
    });

    test('ค่าที่ไม่ใช่รหัสนักศึกษาหรืออีเมลปล่อยผ่านตามเดิม', () {
      expect(normalizeLoginIdentifier('T-1024'), 'T-1024');
      expect(normalizeLoginIdentifier(''), '');
    });
  });
}
