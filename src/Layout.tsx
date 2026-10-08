import { A, useLocation, type RouteSectionProps } from '@solidjs/router';
import { createEffect, createSignal, on } from 'solid-js';

export default function Layout(props: RouteSectionProps) {
	const [menuOpen, setMenuOpen] = createSignal(false);

	// Close the phone menu once a link in it has been followed.
	const location = useLocation();
	createEffect(
		on(
			() => location.pathname,
			() => setMenuOpen(false),
			{ defer: true }
		)
	);

	return (
		<>
			<nav class="navbar navbar-expand-sm bg-dark navbar-dark">
				<div class="container-fluid">
					<A class="navbar-brand d-flex align-items-center" href="/" end aria-label="Accueil">
						<svg
							xmlns="http://www.w3.org/2000/svg"
							width="24"
							height="24"
							fill="currentColor"
							viewBox="0 0 16 16"
							aria-hidden="true"
						>
							<path d="M8.354 1.146a.5.5 0 0 0-.708 0l-6 6A.5.5 0 0 0 1.5 7.5v7a.5.5 0 0 0 .5.5h4.5a.5.5 0 0 0 .5-.5v-4h2v4a.5.5 0 0 0 .5.5H14a.5.5 0 0 0 .5-.5v-7a.5.5 0 0 0-.146-.354L13 5.793V2.5a.5.5 0 0 0-.5-.5h-1a.5.5 0 0 0-.5.5v1.293L8.354 1.146z" />
						</svg>
					</A>
					<button
						class="navbar-toggler"
						type="button"
						aria-controls="navContent"
						aria-expanded={menuOpen()}
						aria-label="Menu"
						onClick={() => setMenuOpen(!menuOpen())}
					>
						<span class="navbar-toggler-icon" />
					</button>
					<div class="collapse navbar-collapse" classList={{ show: menuOpen() }} id="navContent">
						{/* Not `end`: the links stay highlighted on /register/done and /login/done */}
						<ul class="navbar-nav">
							<A class="nav-item nav-link mx-2" href="/register">
								Créer un compte
							</A>
							<A class="nav-item nav-link mx-2" href="/login">
								Se connecter
							</A>
							<A class="nav-item nav-link mx-2" href="/listusers">
								Liste des comptes
							</A>
						</ul>
					</div>
				</div>
			</nav>

			<div id="content" class="container pt-5">
				{props.children}
			</div>
		</>
	);
}
