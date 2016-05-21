Hapi = require "hapi"

uuid = 1;       # Use seq instead of proper unique identifiers for demo only

users =
	john:
		id: 'john',
		password: 'password',
		name: 'John Doe'

home = (request, reply) ->
	reply('<html><head><title>Login page</title></head><body><h3>Welcome ' +
				request.auth.credentials.name +
				'!</h3><br/><form method="get" action="/logout">' +
				'<input type="submit" value="Logout">' +
				'</form></body></html>'
	)

login = (request, reply) ->
	if request.auth.isAuthenticated
		return	reply.redirect '/'
	message = ''
	account = null
	if request.method is 'post'
		if !request.payload.username or !request.payload.password
			message = 'Missing username or password'
		else
			account = users[request.payload.username]
			if !account or account.password isnt request.payload.password
				message = 'Invalid username or password'
	if request.method is 'get' or message
		return reply('<html><head><title>Login page</title></head><body>' +
					(message ? '<h3>' + message + '</h3><br/>' : '') +
					'<form method="post" action="/login">' +
					'Username: <input type="text" name="username"><br>' +
					'Password: <input type="password" name="password"><br/>' +
					'<input type="submit" value="Login"></form></body></html>'
		)

	sid = String ++uuid
	console.log(sid)
	request.server.app.cache.set sid, { account: account }, 0, (err) ->
		if err
			return reply err
		request.cookieAuth.set { sid: sid }
		reply.redirect '/'

logout = (request, reply) ->
	request.cookieAuth.clear()
	reply.redirect('/')

server = new Hapi.Server()
server.connection { port: 8000 }

server.register(require('hapi-auth-cookie'), (err) ->
	if err
		throw err
	
	cache = server.cache { segment: 'sessions', expiresIn: 1000*10 }
	server.app.cache = cache
	
	server.auth.strategy('session', 'cookie', true, {
		password: 'password-should-be-32-characters'
		cookie: 'sid-example'
		redirectTo: '/login'
		isSecure: false
		validateFunc: (request, session, cb) ->
			cache.get(session.sid, (err, cached) ->
				if err
					cb err, false
				if !cached
					return cb null, false
				cb null, true, cached.account
			)
	})
	server.route([{
		path: '/'
		method: 'GET'
		config:
			handler: home
	}
	,
	{
		path: '/login'
		method: ['GET', 'POST']
		config:
			handler: login
			auth: { mode: 'try' }
			plugins: { 'hapi-auth-cookie' : { redirectTo: false } }
	}
	,
	{
		path: '/logout'
		method: 'GET'
		config:
			handler: logout
	}])
	server.start (err) ->
		console.log("started")
)


