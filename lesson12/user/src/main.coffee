module.exports = (server, options, next) ->
	options.model = require('./model') options
	server.route require('./routes') server, options
	next()
