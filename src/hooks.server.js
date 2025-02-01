import { redirect } from '@sveltejs/kit';

const unprotectedRoutes = ['/login', '/register'];

export const handle = async ({ event, resolve }) => {
    const session = event.cookies.get('sb-auth-token');
    const path = event.url.pathname;

    // Allow unprotected routes
    if (unprotectedRoutes.includes(path)) {
        return await resolve(event);
    }

    // Redirect to login if no session
    if (!session && !path.startsWith('/login')) {
        throw redirect(303, '/login');
    }

    return await resolve(event);
}; 