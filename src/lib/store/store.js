import { writable } from 'svelte/store';

export const userType = writable(null);
export const screenType = writable(null);
export const isIframe = writable(true);

const storedTheme = typeof localStorage !== 'undefined' ? 
	localStorage.getItem('theme') !== 'light' : true;  // Default to dark if no preference

export const screenSize = writable({ width: 0, height: 0 });
export const darkMode = writable(storedTheme);

// Subscribe to changes and save to localStorage
if (typeof window !== 'undefined') {
	darkMode.subscribe(value => {
		localStorage.setItem('theme', value ? 'dark' : 'light');
		document.documentElement.classList.toggle('dark-mode', value);
	});
}
