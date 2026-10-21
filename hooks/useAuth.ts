import { create } from 'zustand';

type AuthState = {
  token: string | null;
  studentId: string | null;
  role: 'student' | 'teacher' | null;
  isAuthenticated: boolean;
  login: (token: string, studentId: string, role: 'student' | 'teacher') => void;
  logout: () => void;
};

export const useAuth = create<AuthState>((set) => ({
  token: null,
  studentId: null,
  role: null,
  isAuthenticated: false,
  login: (token, studentId, role) =>
    set({ token, studentId, role, isAuthenticated: true }),
  logout: () =>
    set({ token: null, studentId: null, role: null, isAuthenticated: false }),
}));
