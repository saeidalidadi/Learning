puffer  = require "puffer"
odme 	  = require "odme"
elastic = require "elasticsearch"
config  = require "./config"

db = new puffer { port: config.database.port, host: config.database.host, name: 'default' }

exports.searchEng = new elastic.Client { host: "localhost:#{config.elastic.port}" }

class User extends odme.CB
	source: db
	props:
		name: true
		email: true
		password: true
		posts: true
	PREFIX: 'u'

class Post extends odme.CB
	source: db
	props:
		title: true
		author: true
		body: true
	PREFIX: 'p'

exports.post = Post
exports.user = User

