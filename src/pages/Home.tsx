import { renderSVG } from 'uqr';

import { useTitle } from '../title';

export default function Home() {
	useTitle(() => 'Bienvenue');

	// The site's address without the #/route part, so the QR code opens the home page.
	const siteUrl = window.location.origin + window.location.pathname;

	return (
		<>
			<h1>Bienvenue.</h1>

			<h2>Accès rapide depuis un mobile</h2>
			<div
				class="qr-code d-inline-block p-3 bg-white border rounded"
				innerHTML={renderSVG(siteUrl, { ecc: 'L', border: 2, pixelSize: 6 })}
			/>
			<p class="text-muted mt-2">
				<small>{siteUrl}</small>
			</p>

			<h2>Outils</h2>
			<p>
				MD5 decrypt :{' '}
				<a href="https://md5decrypt.net/" target="_blank">
					https://md5decrypt.net/
				</a>
			</p>
			<p>
				Have I been pwned :{' '}
				<a href="https://haveibeenpwned.com/" target="_blank">
					https://haveibeenpwned.com/
				</a>
			</p>

			<h2>Pour aller plus loin</h2>
			<p>
				MD5 :{' '}
				<a href="https://fr.wikipedia.org/wiki/MD5" target="_blank">
					https://fr.wikipedia.org/wiki/MD5
				</a>
			</p>
		</>
	);
}
