###
#
# main.coffee
# Plugin: post
#
###

module.exports = (server, options, next) ->
	# adding post model
	options.model = require("./model") options
	server.handler('posts', require "./handlers/posts")
	
	# adding server methods
	methods = require "./methods"
	for method in methods
		server.method( method.name, method.method, method.options)

	# adding routes
	server.route require("./routes") server, options
	next()
