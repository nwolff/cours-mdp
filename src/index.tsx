import 'bootstrap/dist/css/bootstrap.min.css';
import './styles.css';

import { HashRouter, Navigate, Route } from '@solidjs/router';
import { render } from 'solid-js/web';

import Layout from './Layout';
import About from './pages/About';
import Account from './pages/Account';
import DeleteAll from './pages/DeleteAll';
import Home from './pages/Home';
import ListUsers from './pages/ListUsers';
import Login from './pages/Login';
import Register from './pages/Register';

// Hash routing (/#/register): GitHub Pages only serves static files, so the
// route has to live in the part of the URL the server never sees.
render(
	() => (
		<HashRouter root={Layout}>
			<Route path="/" component={Home} />
			<Route path="/register" component={Register} />
			<Route path="/login" component={Login} />
			<Route path={['/register/done', '/login/done']} component={Account} />
			<Route path="/listusers" component={ListUsers} />
			<Route path="/_delete" component={DeleteAll} />
			<Route path="/about" component={About} />
			<Route path="*" component={() => <Navigate href="/" />} />
		</HashRouter>
	),
	document.getElementById('root')!
);
