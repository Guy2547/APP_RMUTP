import { api } from './api';

export interface LoginRequest {
  studentId: string;
  atCode: string;
}

export interface LoginResponse {
  token: string;
  studentId: string;
  role: 'student' | 'teacher';
}

export async function loginATCode(data: LoginRequest): Promise<LoginResponse> {
  const response = await api.post<LoginResponse>('/auth/at-login', data);
  return response.data;
}

export async function loginStudent(data: LoginRequest): Promise<LoginResponse> {
  const response = await api.post<LoginResponse>('/auth/student', data);
  return response.data;
}

export async function loginTeacher(data: LoginRequest): Promise<LoginResponse> {
  const response = await api.post<LoginResponse>('/auth/teacher', data);
  return response.data;
}
