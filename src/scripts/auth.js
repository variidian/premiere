export const API = import.meta.env.PUBLIC_API_URL || 'http://localhost:3000';

export async function getUser() {
    const token = localStorage.getItem('token');
    if (!token) return null;
    const res = await fetch(`${API}/auth/me?token=${token}`);
    return await res.json();
}

export async function requireAuth() {
    const user = await getUser();
    if (!user || !user.logged_in) {
        window.location.href = '/';
        alert("Error: Not logged in!")
    }
    return user;
}

export function logout() {
    localStorage.removeItem('token');
    window.location.href = '/';
}
