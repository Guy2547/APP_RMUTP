import { useAuth } from './useAuth';

export function useRole() {
  const { role } = useAuth();
  return {
    role,
    isStudent: role === 'student',
    isTeacher: role === 'teacher',
  };
}
