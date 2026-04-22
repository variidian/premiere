const API = import.meta.env.PUBLIC_API_URL || 'http://localhost:3000';
export async function getUser() {
    const token = localStorage.getItem('token');
    if (!token) return null;
    const res = await fetch(`${API}/api/auth/me?token=${token}`);
    return await res.json();
}