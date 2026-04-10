export async function getUser() {
    const token = localStorage.getItem('token');
    if (!token) return null;
    const res = await fetch(`/api/auth/me?token=${token}`);
    return await res.json();
}