import { defineConfig } from 'vite';
import elm from 'vite-plugin-elm';

export default defineConfig({
	// Relative asset URLs: the same build works under nwolff.github.io/cours-mdp/
	// and on a custom domain. Hash routing (see src/Route.elm) makes this possible.
	base: './',
	plugins: [elm()],
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
	}
});
