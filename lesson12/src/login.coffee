model 	 = require "./model"
messages = require "./messages"
jwtoken	 = require "jsonwebtoken"
config 	 = require "./config"

module.exports =  (request, reply) ->

		if request.method is 'get' and request.auth.isAuthenticated
			reply messages.login.loggedin
		else if request.method is 'get'
			return reply.view 'login'

		else
			payload = request.payload
			
			if request.auth.isAuthenticated
				reply messages.login.loggedin

			else if !payload.email or !payload.password
				return reply.view 'login', { message: messages.login.invalid }

			else
				model.isRegistered payload.email, (registered, user) ->
					if !registered
						reply.view 'login', { message: messages.login.unregistered }
					else if user.password is payload.password
						uid = String ++request.server.app.uid
						request.server.app.logins[uid] = request.payload.email
						cr = { email: payload.email, id: uid }
						reply.redirect "/?token=#{jwtoken.sign(cr, config.tokenKey, { expiresIn: "1day" })}"
						#reply(messages.login.success).header('Autherization', jwtoken.sign(cr, config.tokenKey, { expiresIn: "1day" }))

					else
						reply.view 'login', { message: messages.login.invalid }


