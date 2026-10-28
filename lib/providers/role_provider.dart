import 'package:flutter/foundation.dart';

enum AppRole { student, teacher }

class RoleProvider extends ChangeNotifier {
  AppRole _role = AppRole.student;

  AppRole get role => _role;
  bool get isTeacher => _role == AppRole.teacher;
  bool get isStudent => _role == AppRole.student;

  void setRole(AppRole role) {
    _role = role;
    notifyListeners();
  }

  void setRoleString(String value) {
    _role = (value == 'teacher') ? AppRole.teacher : AppRole.student;
    notifyListeners();
  }
}
