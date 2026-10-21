export type UserRole = 'student' | 'teacher';

export interface User {
  id: string;
  studentId: string;
  name: string;
  email: string;
  role: UserRole;
  faculty: string;
  major: string;
  year: number;
}

export interface Course {
  id: string;
  code: string;
  name: string;
  section: string;
  credits: number;
  instructor: string;
  room: string;
  schedule: string;
}

export interface Grade {
  courseCode: string;
  courseName: string;
  midterm: number;
  final: number;
  coursework: number;
  total: number;
  letter: string;
  status: 'submitted' | 'draft';
}

export interface ActivityTranscript {
  studentId: string;
  totalActivities: number;
  totalTimes: number;
  categories: ActivityCategory[];
}

export interface ActivityCategory {
  name: string;
  total: number;
  confirmed: number;
  unconfirmed: number;
}
