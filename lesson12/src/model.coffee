puffer  = require "puffer"
odme 	  = require "odme"
elastic = require "elasticsearch"
config  = require "./config"

db = new puffer { port: config.database.port, host: config.database.host, name: 'default' }

searchEng = new elastic.Client { host: "localhost:#{config.elastic.port}" }

exports.search = (payload) ->
	isRegistered: (cb) ->
		searchEng.search({
			index: 'blog'
			type: 'users'
			body:
				query:
					match: { email: payload.email }
		}).then (doc) ->
			if doc.hits.total is 1 and payload.email is  doc.hits.hits[0]._source.doc.email
				cb(true, doc.hits.hits[0]._source.doc)
			else cb(false)

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

