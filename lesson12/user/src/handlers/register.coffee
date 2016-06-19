messages = require "../messages"

module.exports = (request, reply, options) ->
  model = options.model
  if request.method is 'get'
    reply.view 'register'
  else
    payload = request.payload
    if !payload.email or !payload.name or !payload.password
      reply.view('register', { message: messages.signup.isn_payload })
    else
      model.isRegistered payload.email, (registered) ->
        if registered
          reply.view('register', { message: messages.signup.before_registered })
        else
          user = { name: payload.name, email: payload.email, password: payload.password }
          model.setUser user, (result) ->
            if result
              reply.view('login', { message: messages.signup.success })

