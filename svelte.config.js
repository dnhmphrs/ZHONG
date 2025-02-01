import adapter from '@sveltejs/adapter-vercel';
import { vitePreprocess } from '@sveltejs/kit/vite';

const config = {
	kit: {
		adapter: adapter(),
		prerender: {
			enabled: false
		}
	},
	preprocess: vitePreprocess()
};

export default config;
