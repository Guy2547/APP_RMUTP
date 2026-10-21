import { create } from 'zustand';
import { createJSONStorage, persist } from 'zustand/middleware';

type AuthStore = {
  token: string | null;
  studentId: string | null;
  role: 'student' | 'teacher' | null;
  setAuth: (token: string, studentId: string, role: 'student' | 'teacher') => void;
  clearAuth: () => void;
};

export const useAuthStore = create<AuthStore>()(
  persist(
    (set) => ({
      token: null,
      studentId: null,
      role: null,
      setAuth: (token, studentId, role) =>
        set({ token, studentId, role }),
      clearAuth: () =>
        set({ token: null, studentId: null, role: null }),
    }),
    {
      name: 'rmutp-auth',
      storage: createJSONStorage(() => ({
        getItem: (key) => {
          if (typeof localStorage !== 'undefined') {
            return Promise.resolve(localStorage.getItem(key));
          }
          return Promise.resolve(null);
        },
        setItem: (key, value) => {
          if (typeof localStorage !== 'undefined') {
            localStorage.setItem(key, value);
          }
          return Promise.resolve();
        },
        removeItem: (key) => {
          if (typeof localStorage !== 'undefined') {
            localStorage.removeItem(key);
          }
          return Promise.resolve();
        },
      })),
    }
  )
);
