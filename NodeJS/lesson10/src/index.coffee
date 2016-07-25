Hapi = require "hapi"

uuid = 1
users =
  admin: { name: 'Arash', password: 'admin' }

view = (reply, state, message) ->
  if  state? and state is 'authenticated'
    return reply '<html><head><title>Login page</title></head><body><h3>Welcome ' +
      (message ? '') +
      '!</h3><br/><form method="post" action="/logout">' +
      '<input type="submit" value="Logout">' +
      '</form></body></html> '
  else
    return reply('<html><head><title>Login page</title></head><body>' +
          (message ? 'wellcome') +
          '<form method="post" action="/login">' +
          'Username: <input type="text" name="username"><br>' +
          'Password: <input type="password" name="password"><br/>' +
          '<input type="submit" value="Login"></form></body></html>'
    )

server = new Hapi.Server()

cache = server.cache({ segment: 'sessions', expiresIn: 1000*60*5 })
server.app.cache = cache

server.connection({ port: 8010 , host: 'localhost' })

server.register(require("hapi-auth-cookie"), (error) ->

  
  server.auth.strategy('session', 'cookie', true, {
    password: 'password-should-be-32-characters'
    cookie: 'sid-example'
    redirectTo: '/'
    isSecure: false
    validateFunc: (request, session, cb) ->
      cache.get(session.sid, (err, cached) ->
        if err
          cb(err, false)
        if !cached
          return cb(null, false)
        return cb(null, true, cached.account)
      )
  })

  server.route([{
    path: '/'
    method: 'GET'
    config:
      auth: { mode: 'try' }
      plugins: {'hapi-auth-cookie' : { redirectTo: false } }
      handler: (request, reply) ->
        if request.auth.isAuthenticated
          view(reply, 'authenticated', 'You are authenticated')
        else
          view(reply)
  }
  ,
  {
    path: '/login'
    method: 'POST'
    config:
      plugins: { 'hapi-auth-cookie' : { redirectTo: false } }
      handler: (request, reply) ->
        console.log request.auth
        if request.auth.isAuthenticated
          state = 'authenticated'
          message = 'You are loged in'
          view(reply, state, message)
        else if !request.payload.username or !request.payload.password
          state = 'invalid'
          message = 'username or password is not valid'
          view(reply, state, message)
        else
          account = users[request.payload.username]
          if !account or  account.password isnt request.payload.password
            state = 'invalid'
            message = 'Username or password is not valid'
          sid = String(++uuid)
          request.server.app.cache.set(sid, { account: account }, 0, (error) ->
            if error
              console.log error
            request.cookieAuth.set { sid: sid }
            message = "You are authenticated #{account.name} and is valid just #{cache.rule.expiresIn / 1000 } seconds"
            state = 'authenticated'
            view(reply, state, message)
          )
      auth: { mode: 'try' }
  }
  ,
  {
    path: '/hello/{name}'
    method: 'GET'
    handler: (request, reply) ->
      console.log request.params.name.toLowerCase()
      if request.auth.isAuthenticated and request.params.name.toLowerCase() is request.auth.credentials.name.toLowerCase()
        reply("#{ request.auth.credentials.name } you have access to this API")
      else
        reply('<h3>You have not access by this name<h3>')
  }
  ,
  {
    path: '/ping'
    method: 'GET'
    config:
      auth: { mode: 'try' }
      plugins: { 'hapi-auth-cookie': { redirectTo: false } }
      handler: (request, reply) ->
        if request.auth.isAuthenticated
          return reply 'pong'
        else reply 'I will say pong if login'
  }
  ,
  {
    path: '/logout'
    method: 'POST'
    handler: (request, reply) ->
      request.cookieAuth.clear()
      reply.redirect('/')
  }])

  server.start (error) ->
    if error
      throw  'Error'
    console.log "Server running at: #{server.info.uri}"
)
