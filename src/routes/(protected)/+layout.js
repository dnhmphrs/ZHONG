import { redirect } from '@sveltejs/kit';
import { browser } from '$app/environment';

export const load = async ({ parent }) => {
	const data = await parent();
	return data;
};

export const prerender = false; 