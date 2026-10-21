import { api } from './api';

export interface AttendanceRecord {
  id: string;
  courseCode: string;
  courseName: string;
  date: string;
  status: 'present' | 'late' | 'absent';
}

export async function getAttendance(): Promise<AttendanceRecord[]> {
  const response = await api.get<AttendanceRecord[]>('/attendance');
  return response.data;
}

export async function checkInQR(roomCode: string): Promise<{ success: boolean }> {
  const response = await api.post<{ success: boolean }>('/attendance/checkin', { roomCode });
  return response.data;
}
