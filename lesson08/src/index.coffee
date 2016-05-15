Hapi = require "hapi"
server = new Hapi.Server()

server.connection({ port: 8080, host: 'localhost'})

sayhi = (name, next) ->
	msg = "Hi #{name}"
	next(null, msg)

server.method('sayhi', sayhi)

server.route({
	path: '/{name}'
	method: 'GET'
	handler: (request, reply) ->
		server.methods.sayhi request.params.name, (err, result) ->
			reply(result)
})

server.start (err) ->
	console.log "Server is running at: #{server.info.uri}"
