const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'https://api.mytalabaty.com/api';

export function getAdminToken(): string | null {
  if (typeof window === 'undefined') return null;
  return localStorage.getItem('talabaty_admin_token');
}

export function setAdminToken(token: string) {
  if (typeof window !== 'undefined') {
    localStorage.setItem('talabaty_admin_token', token);
  }
}

export function clearAdminToken() {
  if (typeof window !== 'undefined') {
    localStorage.removeItem('talabaty_admin_token');
    localStorage.removeItem('talabaty_admin_user');
  }
}

export function getAdminUser() {
  if (typeof window === 'undefined') return null;
  const str = localStorage.getItem('talabaty_admin_user');
  if (!str) return null;
  try {
    return JSON.parse(str);
  } catch (_) {
    return null;
  }
}

export async function adminFetch(endpoint: string, options: RequestInit = {}) {
  const token = getAdminToken();
  const headers: Record<string, string> = {
    'Content-Type': 'application/json',
    ...(options.headers as Record<string, string>),
  };

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  const url = `${API_BASE_URL}${endpoint.startsWith('/') ? endpoint : `/${endpoint}`}`;

  const response = await fetch(url, {
    ...options,
    headers,
  });

  if (response.status === 401 || response.status === 403) {
    if (endpoint !== '/auth/login' && typeof window !== 'undefined') {
      // Clear token on auth failure
      clearAdminToken();
      if (!window.location.pathname.includes('/admin/login')) {
        window.location.href = '/admin/login?error=session_expired';
      }
    }
  }

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.error || data.message || 'حدث خطأ في طلب النظام');
  }

  return data;
}
