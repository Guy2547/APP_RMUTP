export const COLORS = {
  dark: '#420671',
  main: '#4D287B',
  mid: '#652D91',
  light: '#7632AB',
  gold: '#F6DC04',
  cream: '#F7E7BB',
  orange: '#FFA242',
  bg: '#F5F3FA',
  white: '#ffffff',
  black: '#000000',
  red: '#ff4d4d',
  green: '#2ecc71',
  amber: '#f59e0b',
} as const;

export const FONTS = {
  regular: 'Kanit',
  bold: 'Kanit-Bold',
} as const;

export const API_ENDPOINTS = {
  LOGIN_STUDENT: '/auth/student',
  LOGIN_TEACHER: '/auth/teacher',
  LOGIN_ATCODE: '/auth/at-login',
  ATCODE_PRINT: '/atcode/print',
  ATCODE_SUMMARY: '/atcode/summary',
  ATCODE_CATEGORIES: '/atcode/categories',
  ATTENDANCE: '/attendance',
  COURSES: '/courses',
  GRADES: '/grades',
  NEWS: '/news',
  REQUESTS: '/requests',
} as const;
