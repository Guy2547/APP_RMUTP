import { z } from 'zod';

export const loginSchema = z.object({
  studentId: z.string().min(1, 'กรุณากรอกรหัสนักศึกษา'),
  atCode: z.string().min(1, 'กรุณากรอกรหัส AT-Code'),
});

export type LoginFormData = z.infer<typeof loginSchema>;

export const requestSchema = z.object({
  title: z.string().min(1, 'กรุณากรอกหัวข้อคำขอ'),
  description: z.string().min(1, 'กรุณากรอกรายละเอียด'),
});

export type RequestFormData = z.infer<typeof requestSchema>;
