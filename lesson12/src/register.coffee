model = require "./model"
messages = require "./messages"

module.exports = (request, reply) ->

	if request.method is 'get'
		reply.view 'register'
	else
		payload = request.payload
		if !payload.email or !payload.name or !payload.password
			reply.view('register', { message: messages.signup.isn_payload})
		else
			model.search(payload).isRegistered (registered) ->
				if registered
					reply.view('register', { message: messages.signup.before_registered })
				else
					user = new model.user payload
					user.create(true).then () ->
						reply.view('login', { message: messages.signup.success })

