import axios, { AxiosInstance } from 'axios';

export const API_BASE_URL = 'https://api.rmutp.ac.th';

export const api: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

api.interceptors.request.use((config) => {
  const token = typeof localStorage !== 'undefined' ? localStorage.getItem('token') : null;
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      if (typeof localStorage !== 'undefined') {
        localStorage.removeItem('token');
      }
    }
    return Promise.reject(error);
  }
);
