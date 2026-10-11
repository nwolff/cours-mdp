import { formatDateTime } from '../format';
import { useTitle } from '../title';

const REPO_URL = 'https://github.com/nwolff/cours-mdp';

/** Unlisted page identifying the deployed build. */
export default function About() {
	useTitle(() => 'À propos');

	return (
		<>
			<h1>À propos</h1>

			<dl class="row">
				<dt class="col-sm-3">Compilé le</dt>
				<dd class="col-sm-9">{formatDateTime(new Date(__BUILD_DATE__))}</dd>

				<dt class="col-sm-3">Dépôt</dt>
				<dd class="col-sm-9">
					<a href={REPO_URL}>{REPO_URL}</a>
				</dd>

				<dt class="col-sm-3">Commit</dt>
				<dd class="col-sm-9">
					<a href={`${REPO_URL}/commit/${__GIT_HASH__}`}>
						<code>{__GIT_HASH__}</code>
					</a>
				</dd>
			</dl>
		</>
	);
}
