import { defineConfig } from 'vitest/config';
import solid from 'vite-plugin-solid';

export default defineConfig({
	// Relative asset URLs: the same build works under nwolff.github.io/cours-mdp/
	// and on a custom domain. Hash routing (see src/index.tsx) makes this possible.
	base: './',
	plugins: [solid()],
	build: {
		rolldownOptions: {
			output: {
				// The Firestore SDK alone is ~400 kB, over Vite's 500 kB warning threshold
				// once the app is added. A separate chunk keeps it cached across deploys.
				codeSplitting: {
					groups: [{ name: 'firebase', test: /node_modules[\\/]@?firebase/ }]
				}
			}
		}
	},
	test: {
		// The tests cover plain TypeScript modules, not components: no DOM needed.
		environment: 'node'
	}
});
