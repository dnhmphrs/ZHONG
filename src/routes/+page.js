// since there's no dynamic data here, we can prerender
// it so that it gets served as a static asset in production
// export const prerender = true;

import { redirect } from '@sveltejs/kit';

export const load = () => {
    throw redirect(303, '/login');
};
