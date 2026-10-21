import { api } from './api';

export interface ATCodeRequest {
  studentId: string;
  atCode: string;
}

export interface ActivitySummary {
  totalActivities: number;
  totalTimes: number;
  confirmedActivities: number;
  confirmedTimes: number;
  unconfirmedActivities: number;
  unconfirmedTimes: number;
}

export interface ActivityCategory {
  name: string;
  total: number;
  confirmed: number;
  unconfirmed: number;
}

export async function printATCode(data: ATCodeRequest): Promise<{ pdfUrl: string }> {
  const response = await api.post<{ pdfUrl: string }>('/atcode/print', data);
  return response.data;
}

export async function getActivitySummary(): Promise<ActivitySummary> {
  const response = await api.get<ActivitySummary>('/atcode/summary');
  return response.data;
}

export async function getActivityCategories(): Promise<ActivityCategory[]> {
  const response = await api.get<ActivityCategory[]>('/atcode/categories');
  return response.data;
}
